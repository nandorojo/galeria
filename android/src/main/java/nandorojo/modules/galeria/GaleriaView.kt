package nandorojo.modules.galeria


import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
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


class GaleriaView(context: Context) : ViewGroup(context) {
    private lateinit var viewer: ImageViewerBuilder
    lateinit var urls: Array<String>
    val onIndexChange by EventDispatcher()
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
                if (edgeToEdge) {
                    viewer.setViewerFactory(object : ImageViewerDialogFragment.Factory() {
                        override fun build() = EdgeToEdgeImageViewerDialogFragment(
                            theme.toAppearanceLightSystemBars()
                        )
                    })
                }
                childView.setOnClickListener {
                    setupConfig()
                    if (!disableHiddenOriginalImage) {
                        viewer.setViewerCallback(CustomViewerCallback(childView as ImageView) { index ->
                            onIndexChange(mapOf("currentIndex" to index))
                        })
                    }

                    viewer.show()

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




