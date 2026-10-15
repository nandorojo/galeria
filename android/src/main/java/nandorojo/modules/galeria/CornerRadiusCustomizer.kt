package nandorojo.modules.galeria

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ValueAnimator
import android.graphics.Outline
import android.graphics.RectF
import android.view.View
import android.view.ViewOutlineProvider
import android.view.ViewTreeObserver
import android.view.animation.DecelerateInterpolator
import android.widget.ImageView
import androidx.recyclerview.widget.RecyclerView
import com.github.iielse.imageviewer.R
import com.github.iielse.imageviewer.core.VHCustomizer
import com.github.iielse.imageviewer.viewholders.PhotoViewHolder
import com.github.iielse.imageviewer.utils.Config
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/** Rounds the visible image without changing the viewer's bounds or image matrix. */
internal class CornerRadiusCustomizer(
    private var radius: Float,
    private var thumbnailWidth: Int,
    private var thumbnailHeight: Int,
) : VHCustomizer {
    private var fallbackImage: ImageView? = null
    private var fallbackTree: ViewTreeObserver? = null
    private var fallbackDraw: ViewTreeObserver.OnPreDrawListener? = null
    private var fallbackAnimator: ValueAnimator? = null
    private var fallbackClosing = false
    private var afterClose: (() -> Unit)? = null

    fun setThumbnail(width: Int, height: Int, radius: Float) {
        thumbnailWidth = width
        thumbnailHeight = height
        this.radius = radius
    }

    override fun initialize(type: Int, viewHolder: RecyclerView.ViewHolder) {
        if (viewHolder !is PhotoViewHolder) return

        val image = viewHolder.itemView.findViewById<ImageView>(R.id.photoView) ?: return
        image.outlineProvider = ImageOutline()
        image.clipToOutline = true
    }

    fun onInit(viewHolder: RecyclerView.ViewHolder) {
        if (viewHolder !is PhotoViewHolder) return
        val image = viewHolder.itemView.findViewById<ImageView>(R.id.photoView) ?: return
        prepareFallback(image, closing = false)
    }

    fun onRelease(viewHolder: RecyclerView.ViewHolder) {
        // A second close must not cancel the animation holding the dismissal callback.
        if (afterClose != null) return
        if (viewHolder !is PhotoViewHolder) return
        val image = viewHolder.itemView.findViewById<ImageView>(R.id.photoView) ?: return
        (image.outlineProvider as? ImageOutline)?.captureClosingBounds(image)
        prepareFallback(image, closing = true)
    }

    fun onBeforeDismiss(finish: () -> Unit) {
        val container = fallbackImage?.parent as? View
        if (
            fallbackClosing && fallbackImage != null && radius.isFinite() && radius > 0f &&
            container?.width == thumbnailWidth && container.height == thumbnailHeight
        ) {
            afterClose = finish
            if (fallbackAnimator == null) startFallback()
        } else finish()
    }

    fun release() {
        afterClose = null
        fallbackAnimator?.cancel()
        fallbackAnimator = null
        removeFallbackDraw()
        fallbackImage = null
    }

    private fun prepareFallback(image: ImageView, closing: Boolean) {
        release()
        val outline = image.outlineProvider as? ImageOutline ?: return
        if (!closing) outline.fallbackExpansion = 0f
        fallbackImage = image
        fallbackClosing = closing
        fallbackTree = image.viewTreeObserver
        fallbackDraw = ViewTreeObserver.OnPreDrawListener {
            val container = image.parent as? View
            if (container != null && container.width > 0 && container.height > 0) {
                if (container.width != thumbnailWidth || container.height != thumbnailHeight || radius <= 0f) {
                    outline.fallbackExpansion = 1f
                    removeFallbackDraw()
                    fallbackImage = null
                } else if (image.scaleType == if (closing) ImageView.ScaleType.CENTER_CROP else ImageView.ScaleType.FIT_CENTER) {
                    // The native helper changes scale type in its posted transition work.
                    // Starting in that pre-draw joins the same animation frame without a handoff timer.
                    startFallback()
                }
            }
            true
        }.also { fallbackTree?.addOnPreDrawListener(it) }
        image.invalidateOutline()
    }

    private fun startFallback() {
        val image = fallbackImage ?: return
        val outline = image.outlineProvider as? ImageOutline ?: return
        removeFallbackDraw()
        val animator = ValueAnimator.ofFloat(outline.fallbackExpansion, if (fallbackClosing) 0f else 1f).apply {
            duration = Config.DURATION_TRANSITION
            interpolator = DecelerateInterpolator()
            addUpdateListener {
                outline.fallbackExpansion = it.animatedValue as Float
                image.invalidateOutline()
            }
            addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    fallbackAnimator = null
                    fallbackImage = null
                    val finish = afterClose
                    afterClose = null
                    finish?.invoke()
                }
            })
        }
        fallbackAnimator = animator
        animator.start()
    }

    private fun removeFallbackDraw() {
        fallbackDraw?.let { draw ->
            fallbackTree?.takeIf { it.isAlive }?.removeOnPreDrawListener(draw)
        }
        fallbackDraw = null
        fallbackTree = null
    }

    private inner class ImageOutline : ViewOutlineProvider() {
        private var closingBounds: RectF? = null
        var fallbackExpansion = 1f

        fun captureClosingBounds(image: ImageView) {
            val drawable = image.drawable ?: return
            if (drawable.intrinsicWidth <= 0 || drawable.intrinsicHeight <= 0) return

            // Capture before the posted closing transition changes scale type or bounds.
            // This also preserves the starting image rectangle after pinch-to-zoom/panning.
            closingBounds = RectF(
                0f, 0f, drawable.intrinsicWidth.toFloat(), drawable.intrinsicHeight.toFloat(),
            ).also { image.imageMatrix.mapRect(it) }
        }

        override fun getOutline(view: View, outline: Outline) {
            val image = view as? ImageView ?: return
            val container = image.parent as? View ?: return
            if (image.width <= 0 || image.height <= 0) return
            if (!radius.isFinite() || radius <= 0f) {
                outline.setRect(0, 0, image.width, image.height)
                return
            }

            // ChangeBounds and ChangeImageTransform share the same interpolated fraction.
            val widthTravel = container.width - thumbnailWidth
            val heightTravel = container.height - thumbnailHeight
            val expansion = when {
                abs(heightTravel) > abs(widthTravel) ->
                    (image.height - thumbnailHeight).toFloat() / heightTravel
                widthTravel != 0 ->
                    (image.width - thumbnailWidth).toFloat() / widthTravel
                else -> fallbackExpansion
            }.coerceIn(0f, 1f)

            val currentRadius = radius * (1f - expansion)
            outline.setRoundRect(0, 0, image.width, image.height, currentRadius)

            // Fullscreen remains unclipped inside the view, including during drag/zoom.
            if (expansion >= 1f) return
            val drawable = image.drawable ?: return
            val drawableWidth = drawable.intrinsicWidth.toFloat()
            val drawableHeight = drawable.intrinsicHeight.toFloat()
            if (drawableWidth <= 0f || drawableHeight <= 0f) return

            val cropScale = max(thumbnailWidth / drawableWidth, thumbnailHeight / drawableHeight)
            val cropWidth = drawableWidth * cropScale
            val cropHeight = drawableHeight * cropScale
            // Match AndroidX ChangeImageTransform's rounded CENTER_CROP translation.
            val cropLeft = ((thumbnailWidth - cropWidth) / 2f).roundToInt().toFloat()
            val cropTop = ((thumbnailHeight - cropHeight) / 2f).roundToInt().toFloat()

            val fitScale = min(container.width / drawableWidth, container.height / drawableHeight)
            val fitWidth = drawableWidth * fitScale
            val fitHeight = drawableHeight * fitScale
            val fullLeft = closingBounds?.left ?: (container.width - fitWidth) / 2f
            val fullTop = closingBounds?.top ?: (container.height - fitHeight) / 2f
            val fullRight = closingBounds?.right ?: (fullLeft + fitWidth)
            val fullBottom = closingBounds?.bottom ?: (fullTop + fitHeight)

            // PhotoView.imageMatrix reports its attacher, not animateTransform's live matrix.
            // Interpolating the endpoint rectangle follows the native matrix animation
            // without reading that stale matrix or introducing another crop animation.
            val left = interpolate(cropLeft, fullLeft, expansion).coerceIn(0f, image.width.toFloat())
            val top = interpolate(cropTop, fullTop, expansion).coerceIn(0f, image.height.toFloat())
            val right = interpolate(cropLeft + cropWidth, fullRight, expansion)
                .coerceIn(0f, image.width.toFloat())
            val bottom = interpolate(cropTop + cropHeight, fullBottom, expansion)
                .coerceIn(0f, image.height.toFloat())

            if (right > left && bottom > top) {
                outline.setRoundRect(
                    left.roundToInt(), top.roundToInt(), right.roundToInt(), bottom.roundToInt(),
                    currentRadius,
                )
            }
        }

        private fun interpolate(start: Float, end: Float, fraction: Float): Float =
            start + (end - start) * fraction
    }
}
