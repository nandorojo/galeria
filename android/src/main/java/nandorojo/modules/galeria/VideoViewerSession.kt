package nandorojo.modules.galeria

import android.content.ContentResolver
import android.graphics.Bitmap
import android.net.Uri
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import androidx.annotation.OptIn
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.ui.PlayerControlView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.github.iielse.imageviewer.core.ImageLoader
import com.github.iielse.imageviewer.core.Photo
import com.github.iielse.imageviewer.core.VHCustomizer
import com.github.iielse.imageviewer.core.ViewerCallback
import com.github.iielse.imageviewer.utils.Config
import com.github.iielse.imageviewer.viewholders.VideoViewHolder
import com.github.iielse.imageviewer.widgets.video.ExoVideoView2

/** Owns playback for one presentation of the native gallery. */
@OptIn(UnstableApi::class)
class VideoViewerSession(
    private val autoPlayVideo: Boolean,
    private val thumbnail: (Int) -> Bitmap?,
    private val onIndexChange: (Int) -> Unit,
    private val originalImage: ImageView?,
) : ImageLoader, VHCustomizer, ViewerCallback {
    private val controls = mutableMapOf<VideoViewHolder, PlayerControlView>()
    private var activeVideo: VideoViewHolder? = null
    private var released = false
    var isForeground = true

    override fun initialize(type: Int, viewHolder: RecyclerView.ViewHolder) {
        if (viewHolder !is VideoViewHolder) return
        val control = PlayerControlView(viewHolder.itemView.context)
        viewHolder.binding.videoView.setOnClickListener {
            if (control.isFullyVisible) control.hide() else control.show()
        }
        viewHolder.binding.root.addView(
            control,
            FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
        )
        controls[viewHolder] = control
    }

    override fun load(view: ImageView, data: Photo, viewHolder: RecyclerView.ViewHolder) {
        val source = data.extra() as String
        val resourceId = view.resources.getIdentifier(source, "drawable", view.context.packageName)
        val model: Any = if (resourceId != 0) resourceId else source
        Glide.with(view).load(model).placeholder(view.drawable).into(view)
    }

    override fun load(exoVideoView: ExoVideoView2, data: Photo, viewHolder: RecyclerView.ViewHolder) {
        val holder = viewHolder as VideoViewHolder
        controls[holder]?.player = null
        exoVideoView.release()
        holder.binding.imageView.apply {
            setImageBitmap(thumbnail(data.id().toInt()))
            scaleType = ImageView.ScaleType.FIT_CENTER
            visibility = View.VISIBLE
        }
        val source = data.extra() as String
        // Metro serves bundled assets over HTTP; release builds resolve them to raw resource names.
        val resourceId = exoVideoView.resources.getIdentifier(source, "raw", exoVideoView.context.packageName)
        exoVideoView.prepare(
            if (resourceId != 0) {
                Uri.Builder()
                    .scheme(ContentResolver.SCHEME_ANDROID_RESOURCE)
                    .authority(exoVideoView.context.packageName)
                    .path(resourceId.toString())
                    .build()
                    .toString()
            } else {
                source
            }
        )
    }

    override fun onInit(viewHolder: RecyclerView.ViewHolder, position: Int) {
        originalImage?.animate()?.alpha(0f)?.setDuration(180)?.start()
    }

    override fun onPageSelected(position: Int, viewHolder: RecyclerView.ViewHolder) {
        if (released) return
        pause()
        activeVideo?.let { previous ->
            if (previous !== viewHolder) {
                controls[previous]?.player = null
                previous.binding.videoView.release()
                previous.binding.imageView.visibility = View.VISIBLE
            }
        }
        activeVideo = viewHolder as? VideoViewHolder
        activeVideo?.let { holder ->
            val player = holder.binding.videoView.player()
            if (controls[holder]?.player !== player) {
                player?.addListener(object : Player.Listener {
                    override fun onRenderedFirstFrame() {
                        holder.binding.imageView.visibility = View.GONE
                        player?.removeListener(this)
                    }
                })
            }
            controls[holder]?.apply {
                this.player = player
                show()
            }
            if (autoPlayVideo && isForeground) holder.binding.videoView.resume()
        }
        onIndexChange(position)
    }

    override fun onDrag(viewHolder: RecyclerView.ViewHolder, view: View, fraction: Float) {
        if (viewHolder is VideoViewHolder) controls[viewHolder]?.visibility = View.INVISIBLE
    }

    override fun onRestore(viewHolder: RecyclerView.ViewHolder, view: View, fraction: Float) {
        if (viewHolder is VideoViewHolder) controls[viewHolder]?.visibility = View.VISIBLE
    }

    override fun onRelease(viewHolder: RecyclerView.ViewHolder, view: View) {
        pause()
        if (viewHolder is VideoViewHolder) controls[viewHolder]?.visibility = View.INVISIBLE
        originalImage?.let { image ->
            image.animate().cancel()
            // Restore the thumbnail when the viewer fades its shared element out.
            image.postDelayed({ if (!released) image.alpha = 1f }, maxOf(Config.DURATION_TRANSITION - 20, 0))
        }
    }

    fun pause() {
        activeVideo?.binding?.videoView?.pause()
    }

    fun release() {
        if (released) return
        released = true
        controls.forEach { (holder, control) ->
            control.player = null
            holder.binding.videoView.release()
        }
        controls.clear()
        activeVideo = null
        originalImage?.animate()?.cancel()
        originalImage?.alpha = 1f
    }
}
