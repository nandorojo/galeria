package nandorojo.modules.galeria


import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.graphics.Color
import android.graphics.Bitmap
import android.graphics.Canvas
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.annotation.Keep
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.ViewModelStoreOwner
import com.facebook.react.views.image.ReactImageView
import com.github.iielse.imageviewer.ImageViewerActionViewModel
import com.github.iielse.imageviewer.ImageViewerBuilder
import com.github.iielse.imageviewer.ImageViewerDialogFragment
import com.github.iielse.imageviewer.R
import com.github.iielse.imageviewer.adapter.ItemType
import java.util.Collections
import java.util.WeakHashMap
import com.github.iielse.imageviewer.core.Photo
import com.github.iielse.imageviewer.core.SimpleDataProvider
import com.github.iielse.imageviewer.core.Transformer
import com.github.iielse.imageviewer.utils.Config
import expo.modules.kotlin.viewevent.EventDispatcher


class StringPhoto(private val id: Long, private val data: String, private val video: Boolean) : Photo {
    override fun id(): Long = id

    override fun itemType(): Int = if (video) ItemType.VIDEO else ItemType.PHOTO

    override fun extra(): Any = data
}

fun convertToPhotos(ids: Array<String>, mediaTypes: Array<String>): List<Photo> {
    return ids.mapIndexed { index, data ->
        StringPhoto(index.toLong(), data, mediaTypes.getOrNull(index) == "video")
    }
}


@Keep
class GaleriaView(context: Context) : ViewGroup(context) {
    lateinit var urls: Array<String>
    var mediaTypes: Array<String> = emptyArray()
    var autoPlayVideo = false

    companion object {
        private val mountedViews: MutableSet<GaleriaView> =
            Collections.newSetFromMap(WeakHashMap<GaleriaView, Boolean>())
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        mountedViews.add(this)
    }

    override fun onDetachedFromWindow() {
        mountedViews.remove(this)
        super.onDetachedFromWindow()
    }

    private fun childImage(view: ViewGroup): ImageView? {
        for (index in view.childCount - 1 downTo 0) {
            val child = view.getChildAt(index)
            if (child.visibility != View.VISIBLE) continue
            if (child is ImageView && child.drawable != null) return child
            if (child is ViewGroup) childImage(child)?.let { return it }
        }
        return null
    }

    private fun imageViewAt(index: Long): ImageView? {
        if (index == initialIndex.toLong() && isAttachedToWindow) return childImage(this)
        return mountedViews.firstOrNull {
            it.initialIndex.toLong() == index && it.urls.contentEquals(urls)
        }?.let { childImage(it) }
    }

    private fun thumbnail(index: Int): Bitmap? {
        val source = imageViewAt(index.toLong()) ?: return null
        if (source.width == 0 || source.height == 0) return null
        // Snapshot the caller's rendered thumbnail, including Fresco-backed images.
        return Bitmap.createBitmap(source.width, source.height, Bitmap.Config.ARGB_8888).also {
            source.draw(Canvas(it))
        }
    }
    val onIndexChange by EventDispatcher()
    val onLongPress by EventDispatcher()
    val onDismiss by EventDispatcher()
    var theme: Theme = Theme.Dark
    var initialIndex: Int = 0
    var disableHiddenOriginalImage = false
    var edgeToEdge = false
    var transitionOffsetY: Int? = null
    var transitionOffsetX: Int? = 0
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

        val photos = convertToPhotos(urls, mediaTypes)
        val clickedData = photos[initialIndex]
        for (i in 0 until parentView.childCount) {
            val childView = parentView.getChildAt(i)
            if (childView is ImageView) {
                var imageViewContext = childView.context
                if (childView is ReactImageView) {
                    val activityContext = getActivity(childView.context)
                    imageViewContext = activityContext
                }
                childView.setOnClickListener {
                    setupConfig()
                    val session = VideoViewerSession(
                        autoPlayVideo = autoPlayVideo,
                        thumbnail = { index -> thumbnail(index) },
                        onIndexChange = { index -> onIndexChange(mapOf("currentIndex" to index)) },
                        originalImage = if (disableHiddenOriginalImage) null else childView,
                    )
                    val viewer = ImageViewerBuilder(
                        context = imageViewContext,
                        dataProvider = SimpleDataProvider(clickedData, photos),
                        imageLoader = session,
                        transformer = object : Transformer {
                            override fun getView(key: Long): ImageView? {
                                val target = imageViewAt(key) ?: return null
                                return fakeStartView(target)
                            }
                        }
                    )
                    viewer.setVHCustomizer(session)
                    viewer.setViewerCallback(session)
                    viewer.setViewerFactory(object : ImageViewerDialogFragment.Factory() {
                        override fun build() = EdgeToEdgeImageViewerDialogFragment(
                            isAppearanceLightSystemBars =
                                if (edgeToEdge) theme.toAppearanceLightSystemBars() else null,
                            onResumeCallback = { session.isForeground = true },
                            onPauseCallback = {
                                session.isForeground = false
                                session.pause()
                            },
                            onDestroyCallback = { session.release() },
                            onDismissCallback = {
                                session.release()
                                onDismiss(emptyMap<String, Any>())
                            },
                        )
                    })
                    viewer.show()
                }
                childView.setOnLongClickListener {
                    onLongPress(emptyMap<String, Any>())
                    true
                }
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
