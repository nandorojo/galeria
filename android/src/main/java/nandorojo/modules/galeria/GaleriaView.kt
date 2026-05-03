package nandorojo.modules.galeria


import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import android.view.ViewGroup
import android.widget.ImageView
import androidx.annotation.Keep
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.ViewModelStoreOwner
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.facebook.react.views.image.ReactImageView
import com.github.iielse.imageviewer.ImageViewerActionViewModel
import com.github.iielse.imageviewer.ImageViewerBuilder
import com.github.iielse.imageviewer.ImageViewerDialogFragment
import com.github.iielse.imageviewer.R
import com.github.iielse.imageviewer.core.ImageLoader
import com.github.iielse.imageviewer.core.Photo
import com.github.iielse.imageviewer.core.SimpleDataProvider
import com.github.iielse.imageviewer.core.Transformer
import com.github.iielse.imageviewer.core.ViewerCallback
import com.github.iielse.imageviewer.utils.Config
import expo.modules.kotlin.viewevent.EventDispatcher


class StringPhoto(private val id: Long, private val data: String) : Photo {
    override fun id(): Long = id

    override fun itemType(): Int = 1

    override fun extra(): Any = data
}

fun convertToPhotos(ids: Array<String>): List<Photo> {
    return ids.mapIndexed { index, data ->
        StringPhoto(index.toLong(), data)  // Use index as the id, and data as the image data.
    }
}


@Keep
class GaleriaView(context: Context) : ViewGroup(context) {
    private lateinit var viewer: ImageViewerBuilder
    lateinit var urls: Array<String>
    val onIndexChange by EventDispatcher()
    val onLongPress by EventDispatcher()
    val onDismiss by EventDispatcher()
    var theme: Theme = Theme.Dark
    var initialIndex: Int = 0
    var disableHiddenOriginalImage = false
    var edgeToEdge = false
    var transitionOffsetY: Int? = null
    var transitionOffsetX: Int? = 0
    var longPressEnabled: Boolean = false
    val viewModel: ImageViewerActionViewModel by lazy {
        ViewModelProvider(getViewModelOwner(context)).get(ImageViewerActionViewModel::class.java)
    }

    fun dismiss()  {
        viewModel.dismiss()
    }
    private fun getViewModelOwner(context: Context): ViewModelStoreOwner {
        val activity = getActivity(context)
            ?: throw IllegalStateException("The provided context ${context.javaClass.name} is not associated with an activity.")
        return activity as ViewModelStoreOwner
    }

    private fun getActivity(context: Context): Activity {
        var ctx = context
        while (ctx is ContextWrapper) {
            if (ctx is Activity) {
                return ctx
            }
            ctx = ctx.baseContext
        }
        throw IllegalStateException("Context does not contain an activity.")
    }

    @SuppressLint("DiscouragedApi", "InternalInsetResource")
    fun getStatusBarHeight(): Int {
        var statusBarHeight = 0
        val resourceId = resources.getIdentifier("status_bar_height", "dimen", "android")
        if (resourceId > 0) {
            statusBarHeight = resources.getDimensionPixelSize(resourceId)
        }
        return statusBarHeight
    }


    private fun setupImageViewer(parentView: ViewGroup) {

        val photos = convertToPhotos(urls)
        val clickedData = photos[initialIndex]
        for (i in 0 until parentView.childCount) {
            val childView = parentView.getChildAt(i)
            if (childView is ImageView) {
                var imageViewContext = childView.context
                if (childView is ReactImageView) {
                    val activityContext = getActivity(childView.context)
                    imageViewContext = activityContext
                }
                viewer = ImageViewerBuilder(
                    context = imageViewContext,
                    dataProvider = SimpleDataProvider(clickedData, photos),
                    imageLoader = SimpleImageLoader(),
                    transformer = object : Transformer {
                        override fun getView(key: Long): ImageView {
                            return fakeStartView(parentView)
                        }
                    }
                )
                viewer.setViewerFactory(object : ImageViewerDialogFragment.Factory() {
                    override fun build() = EdgeToEdgeImageViewerDialogFragment(
                        isAppearanceLightSystemBars =
                            if (edgeToEdge) theme.toAppearanceLightSystemBars() else null,
                        onDismissCallback = { onDismiss(emptyMap<String, Any>()) },
                    )
                })
                childView.setOnClickListener {
                    setupConfig()
                    if (!disableHiddenOriginalImage) {
                        viewer.setViewerCallback(CustomViewerCallback(childView as ImageView) { index ->
                            onIndexChange(mapOf("currentIndex" to index))
                        })
                    }

                    viewer.show()

                }
                if (longPressEnabled) {
                    installLongPressTouch(childView)
                } else {
                    childView.setOnTouchListener(null)
                }
                childView.isLongClickable = false
            } else if (childView is ViewGroup) {
                setupImageViewer(childView)
            }
        }
    }



    private fun fakeStartView(view: View): ImageView {
        val customWidth = view.width
        val customHeight = view.height
        val customLocation = IntArray(2).also { view.getLocationOnScreen(it) }
        val customScaleType = ImageView.ScaleType.CENTER_CROP

        return ImageView(view.context).apply {
            left = 0
            right = customWidth
            top = 0
            bottom = customHeight
            scaleType = customScaleType
            setTag(R.id.viewer_start_view_location_0, customLocation[0])
            setTag(R.id.viewer_start_view_location_1, customLocation[1])
        }
    }

    private fun setupConfig() {
        Config.TRANSITION_OFFSET_Y = transitionOffsetY ?: when (edgeToEdge) {
            true -> 0
            false -> getStatusBarHeight()
        }

        Config.TRANSITION_OFFSET_X = transitionOffsetX ?: 0
        Config.VIEWER_BACKGROUND_COLOR = theme.toImageViewerTheme()
    }


    override fun onLayout(p0: Boolean, p1: Int, p2: Int, p3: Int, p4: Int) {
        setupImageViewer(this)
    }

    /**
     * Wires a long-press detector on top of [childView] using a fixed 500 ms
     * threshold (intentionally independent of the device's
     * [ViewConfiguration.getLongPressTimeout]). This matches the iOS side,
     * which uses [UILongPressGestureRecognizer] with `minimumPressDuration =
     * 0.5`.
     *
     * On ACTION_DOWN we post a 500 ms Runnable; if it fires we emit the
     * [onLongPress] event and remember that. On ACTION_UP we cancel the
     * pending Runnable (a no-op if it already ran) and, if the long-press
     * fired, swallow the UP event so [View.onTouchEvent] never observes the
     * full down/up sequence — which is what suppresses the `setOnClickListener`
     * fallback that otherwise opens the viewer. ACTION_MOVE that exceeds the
     * touch slop, and ACTION_CANCEL, both cancel the pending Runnable.
     *
     * Returning `false` from DOWN/MOVE/non-suppressed UP keeps the existing
     * click handling intact: the View still tracks the press and dispatches
     * the click on UP via the normal flow.
     */
    private fun installLongPressTouch(childView: ImageView) {
        val handler = Handler(Looper.getMainLooper())
        val downPos = floatArrayOf(0f, 0f)
        val touchSlop = ViewConfiguration.get(childView.context).scaledTouchSlop.toFloat()
        var longPressFired = false

        val longPressRunnable = Runnable {
            longPressFired = true
            onLongPress(emptyMap<String, Any>())
        }

        childView.setOnTouchListener { v, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    longPressFired = false
                    downPos[0] = event.rawX
                    downPos[1] = event.rawY
                    handler.postDelayed(longPressRunnable, 500L)
                    false
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = event.rawX - downPos[0]
                    val dy = event.rawY - downPos[1]
                    if (dx * dx + dy * dy > touchSlop * touchSlop) {
                        handler.removeCallbacks(longPressRunnable)
                    }
                    false
                }
                MotionEvent.ACTION_UP -> {
                    handler.removeCallbacks(longPressRunnable)
                    if (longPressFired) {
                        v.isPressed = false
                        true
                    } else {
                        false
                    }
                }
                MotionEvent.ACTION_CANCEL -> {
                    handler.removeCallbacks(longPressRunnable)
                    false
                }
                else -> false
            }
        }
    }


}

class CustomViewerCallback(private val childView: ImageView, private val onIndexChange: (Int) -> Unit) : ViewerCallback {
    override fun onInit(viewHolder: RecyclerView.ViewHolder, position: Int) {
        childView.animate().alpha(0f).setDuration(180).start()

    }


    override fun onRelease(viewHolder: RecyclerView.ViewHolder, view: View) {
        Handler(Looper.getMainLooper()).postDelayed({
            childView.alpha = 1f
        }, 230)
    }

    override fun onPageSelected(position: Int, viewHolder: RecyclerView.ViewHolder) {
        onIndexChange(position)
    }
}

enum class Theme(val value: String) {
    Dark("dark"),
    Light("light");

    fun toAppearanceLightSystemBars(): Boolean {
        return when (this) {
            Dark -> false
            Light -> true
        }
    }

    fun toImageViewerTheme(): Int {
        return when (this) {
            Dark -> Color.BLACK
            Light -> Color.WHITE
        }
    }
}

class SimpleImageLoader : ImageLoader {
    override fun load(view: ImageView, data: Photo, viewHolder: RecyclerView.ViewHolder) {
//        Todo: Since React-Native's Image is using Fresco as the image loader, we may need to handle it differently.
        val it = data.extra() as? String
        Glide.with(view).load(it)
            .placeholder(view.drawable)
            .into(view)
    }
}




