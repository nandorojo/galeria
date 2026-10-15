package nandorojo.modules.galeria

import android.graphics.Outline
import android.graphics.Rect
import android.os.Build
import android.view.View
import com.facebook.react.uimanager.BackgroundStyleApplicator
import com.facebook.react.uimanager.LengthPercentage
import com.facebook.react.uimanager.LengthPercentageType
import com.facebook.react.uimanager.ReactOverflowView
import com.facebook.react.uimanager.style.BorderRadiusProp
import com.facebook.react.uimanager.style.LogicalEdge
import com.facebook.react.views.image.ReactImageView
import kotlin.math.max
import kotlin.math.min

/** Read uniform numeric rounding from the thumbnail and coincident clipping ancestors. */
internal object ThumbnailCornerRadius {
    // RN changed this public resolver from (width, height) -> CornerRadii to (length) -> Float.
    // Reflect only those public methods; consumer rules preserve their names in release builds.
    private val resolve by lazy {
        LengthPercentage::class.java.methods.first {
            it.name == "resolve" && it.parameterTypes.size in 1..2
        }
    }
    private val horizontal by lazy {
        if (resolve.returnType == Float::class.javaPrimitiveType) null
        else resolve.returnType.getMethod("getHorizontal")
    }

    fun read(image: View): Float {
        var current: View = image
        var left = 0
        var top = 0
        var radius = 0f
        while (true) {
            // A scalar radius cannot describe a transformed clipping boundary reliably.
            if (!current.matrix.isIdentity) return 0f
            val overflow = (current as? ReactOverflowView)?.overflow
            val clips = current.clipToOutline || overflow == "hidden" || overflow == "scroll"
            val sameBounds = left == 0 && top == 0 &&
                current.width == image.width && current.height == image.height
            if (sameBounds && (clips || current === image && current is ReactImageView)) {
                radius = max(radius, uniformRadius(current) ?: return 0f)
            }

            if (current is GaleriaView) break
            val parent = current.parent as? View ?: break
            left += current.left - parent.scrollX
            top += current.top - parent.scrollY
            current = parent
        }
        return radius
    }

    /** null means a shape this scalar-radius transition cannot represent. */
    private fun uniformRadius(view: View): Float? {
        // RN clips inside borders, so the outer bounds no longer describe the image clip.
        if (LogicalEdge.values().any { (BackgroundStyleApplicator.getBorderWidth(view, it) ?: 0f) > 0f }) return null

        // Do not mistake the shorthand for the effective shape when corners override it.
        if (BorderRadiusProp.values().any {
            it != BorderRadiusProp.BORDER_RADIUS && BackgroundStyleApplicator.getBorderRadius(view, it) != null
        }) return null

        val radius = BackgroundStyleApplicator.getBorderRadius(view, BorderRadiusProp.BORDER_RADIUS)
        if (radius != null) {
            if (radius.type != LengthPercentageType.POINT) return null
            val result = if (resolve.parameterTypes.size == 1) resolve.invoke(radius, 1f)
                else resolve.invoke(radius, 1f, 1f)
            val pixels = ((horizontal?.invoke(result) ?: result) as Number).toFloat() *
                view.resources.displayMetrics.density
            return if (pixels.isFinite()) pixels.coerceIn(0f, min(view.width, view.height) / 2f) else null
        }

        // A background/shadow outline only describes image clipping when clipToOutline is enabled.
        if (!view.clipToOutline || Build.VERSION.SDK_INT < 24) return 0f
        val outline = Outline()
        view.outlineProvider?.getOutline(view, outline)
        if (outline.isEmpty) return 0f
        val bounds = Rect()
        if (!outline.getRect(bounds) || bounds != Rect(0, 0, view.width, view.height)) return null
        return if (outline.radius.isFinite() && outline.radius >= 0f) {
            min(outline.radius, min(view.width, view.height) / 2f)
        } else null
    }
}
