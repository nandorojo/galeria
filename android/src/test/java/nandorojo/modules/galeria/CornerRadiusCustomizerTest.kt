package nandorojo.modules.galeria

import android.os.Looper
import android.view.View
import android.widget.FrameLayout
import androidx.recyclerview.widget.RecyclerView
import com.github.iielse.imageviewer.ImageViewerAdapterListener
import com.github.iielse.imageviewer.utils.Config
import com.github.iielse.imageviewer.viewholders.PhotoViewHolder
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config as RobolectricConfig
import org.robolectric.annotation.LooperMode
import java.time.Duration

@RunWith(RobolectricTestRunner::class)
@RobolectricConfig(sdk = [28])
@LooperMode(LooperMode.Mode.PAUSED)
class CornerRadiusCustomizerTest {
    @Test
    fun repeatedReleasePreservesPendingDismissal() {
        val holder = photoHolder()
        val corners = CornerRadiusCustomizer(20f, 100, 100)
        corners.initialize(0, holder)
        corners.onRelease(holder)
        var dismissals = 0
        corners.onBeforeDismiss { dismissals++ }

        // Native close has finished, but the full-viewport radius animation still owns dismissal.
        corners.onRelease(holder)
        corners.onRelease(holder)
        assertEquals(0, dismissals)
        finishAnimations()
        assertEquals(1, dismissals)
        corners.release()
    }

    @Test
    fun sessionReleaseCancelsPendingDismissal() {
        val holder = photoHolder()
        val corners = CornerRadiusCustomizer(20f, 100, 100)
        corners.initialize(0, holder)
        corners.onRelease(holder)
        var dismissals = 0
        corners.onBeforeDismiss { dismissals++ }

        corners.release()
        finishAnimations()
        assertEquals(0, dismissals)
    }

    private fun photoHolder(): PhotoViewHolder {
        val parent = FrameLayout(RuntimeEnvironment.getApplication())
        val holder = PhotoViewHolder(parent, object : ImageViewerAdapterListener {
            override fun onInit(viewHolder: RecyclerView.ViewHolder, position: Int) = Unit
            override fun onDrag(viewHolder: RecyclerView.ViewHolder, view: View, fraction: Float) = Unit
            override fun onRestore(viewHolder: RecyclerView.ViewHolder, view: View, fraction: Float) = Unit
            override fun onRelease(viewHolder: RecyclerView.ViewHolder, view: View) = Unit
        })
        val size = View.MeasureSpec.makeMeasureSpec(100, View.MeasureSpec.EXACTLY)
        holder.itemView.measure(size, size)
        holder.itemView.layout(0, 0, 100, 100)
        return holder
    }

    private fun finishAnimations() {
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(Config.DURATION_TRANSITION + 100L))
    }
}
