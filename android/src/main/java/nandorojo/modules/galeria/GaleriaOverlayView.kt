package nandorojo.modules.galeria

import android.annotation.SuppressLint
import android.content.Context
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.accessibility.AccessibilityEvent
import com.facebook.react.bridge.ReactContext
import com.facebook.react.common.annotations.UnstableReactNativeAPI
import com.facebook.react.uimanager.JSTouchDispatcher
import com.facebook.react.uimanager.RootView
import com.facebook.react.uimanager.TouchTargetHelper
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.views.view.ReactViewGroup
import expo.modules.kotlin.AppContext
import expo.modules.kotlin.views.ExpoView
import java.lang.ref.WeakReference

/**
 * `Galeria.Overlay`: React views shown over the viewer of its group's images while it's open.
 *
 * The viewer is a dialog, a window of its own. So, as React Native's `Modal`, this view keeps its children in a
 * [Host] rather than in itself: the viewer puts the host over its photos once open (its overlay view), and lets go
 * of it once closed. The host handles the touches on the overlay's views for React, as the dialog's root.
 */
class GaleriaOverlayView(context: Context, appContext: AppContext) : ExpoView(context, appContext) {
    companion object {
        private val registry = mutableMapOf<String, WeakReference<GaleriaOverlayView>>()

        /** The overlay of the images whose urls are these, if one is shown: the last one put in a window. */
        fun find(urls: Array<String>): GaleriaOverlayView? = registry[groupId(urls)]?.get()

        private fun groupId(urls: Array<String>) = urls.joinToString(",")
    }

    var urls: Array<String>? = null
        set(value) {
            unregister()
            field = value
            register()
        }

    // Only while in a window: not once unmounted, nor while its screen is under another (e.g. of the same images
    // opened again).
    private fun register() {
        urls?.takeIf { it.isNotEmpty() && isAttachedToWindow }?.let { registry[groupId(it)] = WeakReference(this) }
    }

    private fun unregister() {
        urls?.let { if (registry[groupId(it)]?.get() === this) registry.remove(groupId(it)) }
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        register()
    }

    override fun onDetachedFromWindow() {
        unregister()
        super.onDetachedFromWindow()
    }

    val host = Host(context)

    /** Whether the overlay is shown, a tap on a photo toggling it. */
    private var shown = true

    /** Whether a photo is being dragged to close the viewer: the overlay is hidden then, as on iOS. */
    private var dragging = false

    override fun setId(id: Int) {
        super.setId(id)
        // The touches on nothing of the overlay's are the host's, as this view's.
        host.id = id
    }

    override fun addView(child: View?, index: Int) {
        host.addView(child, index)
    }

    override fun getChildCount(): Int = host.childCount

    override fun getChildAt(index: Int): View? = host.getChildAt(index)

    override fun removeView(child: View?) {
        host.removeView(child)
    }

    override fun removeViewAt(index: Int) {
        host.removeView(getChildAt(index))
    }

    // Its children aren't its descendants (as Modal's): the host's own, for accessibility services too.
    override fun addChildrenForAccessibility(outChildren: ArrayList<View>) {
    }

    override fun dispatchPopulateAccessibilityEvent(event: AccessibilityEvent): Boolean = false

    // React measures and lays out the children (the host's: not a LinearLayout's, as ExpoView would measure them).
    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        setMeasuredDimension(MeasureSpec.getSize(widthMeasureSpec), MeasureSpec.getSize(heightMeasureSpec))
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
    }

    /** The host, hidden, to put over the photos of a viewer opening. */
    fun attach(): View {
        (host.parent as? ViewGroup)?.removeView(host)
        host.animate().cancel()
        host.alpha = 0f
        shown = true
        dragging = false
        return host
    }

    fun detach() {
        host.animate().cancel()
        (host.parent as? ViewGroup)?.removeView(host)
    }

    fun fadeIn(delay: Long = 0) = fade(if (shown) 1f else 0f, delay)

    fun fadeOut() = fade(0f)

    fun toggle() {
        shown = !shown
        fadeIn()
    }

    fun drag() {
        if (dragging) return
        dragging = true
        fade(0f)
    }

    /** The photo dragged is put back in place. */
    fun restore() {
        dragging = false
        fadeIn()
    }

    private fun fade(alpha: Float, delay: Long = 0) {
        host.animate().alpha(alpha).setStartDelay(delay).setDuration(235).start()
    }

    /** The overlay's views in the viewer, React's root there, as `Modal`'s. */
    @SuppressLint("ViewConstructor")
    class Host(context: Context) : ReactViewGroup(context), RootView {
        private val touchDispatcher = JSTouchDispatcher(this)
        private val reactContext get() = context as ReactContext
        private val eventDispatcher get() = UIManagerHelper.getEventDispatcherForReactTag(reactContext, id)

        // Over the whole viewer: its overlay view (a ConstraintLayout) doesn't size it, a view without constraints.
        private val coverParent = View.OnLayoutChangeListener { _, left, top, right, bottom, _, _, _, _ ->
            cover(right - left, bottom - top)
        }

        override fun onAttachedToWindow() {
            super.onAttachedToWindow()
            (parent as? View)?.let {
                it.addOnLayoutChangeListener(coverParent)
                cover(it.width, it.height)
            }
        }

        override fun onDetachedFromWindow() {
            (parent as? View)?.removeOnLayoutChangeListener(coverParent)
            super.onDetachedFromWindow()
        }

        private fun cover(width: Int, height: Int) {
            if (width == this.width && height == this.height && left == 0 && top == 0) return
            measure(MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
            layout(0, 0, width, height)
        }

        /** Whether the touch going on is on one of the overlay's views: else it's the photos'. */
        private var isOverlayTouch = false

        override fun dispatchTouchEvent(event: MotionEvent): Boolean {
            if (event.actionMasked == MotionEvent.ACTION_DOWN) {
                isOverlayTouch = TouchTargetHelper.findTargetTagForTouch(event.x, event.y, this) != id
            }
            return isOverlayTouch && super.dispatchTouchEvent(event)
        }

        override fun onInterceptTouchEvent(event: MotionEvent): Boolean {
            eventDispatcher?.let { touchDispatcher.handleTouchEvent(event, it, reactContext) }
            return super.onInterceptTouchEvent(event)
        }

        @SuppressLint("ClickableViewAccessibility")
        override fun onTouchEvent(event: MotionEvent): Boolean {
            eventDispatcher?.let { touchDispatcher.handleTouchEvent(event, it, reactContext) }
            super.onTouchEvent(event)
            return true
        }

        @OptIn(UnstableReactNativeAPI::class)
        override fun onChildStartedNativeGesture(childView: View?, ev: MotionEvent) {
            eventDispatcher?.let { touchDispatcher.onChildStartedNativeGesture(ev, it, reactContext) }
        }

        override fun onChildEndedNativeGesture(childView: View, ev: MotionEvent) {
            eventDispatcher?.let { touchDispatcher.onChildEndedNativeGesture(ev, it) }
        }

        override fun handleException(t: Throwable) {
            reactContext.handleException(RuntimeException(t))
        }

        override fun requestDisallowInterceptTouchEvent(disallowIntercept: Boolean) {
            // Still sees the touches its children handle, for React.
        }
    }
}
