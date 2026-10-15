package nandorojo.modules.galeria

import android.content.Context
import android.graphics.Outline
import android.view.View
import android.view.ViewOutlineProvider
import android.widget.FrameLayout
import android.widget.ImageView
import com.facebook.react.internal.featureflags.ReactNativeFeatureFlagsForTests
import com.facebook.react.uimanager.BackgroundStyleApplicator
import com.facebook.react.uimanager.DisplayMetricsHolder
import com.facebook.react.uimanager.LengthPercentage
import com.facebook.react.uimanager.LengthPercentageType
import com.facebook.react.uimanager.style.BorderRadiusProp
import com.facebook.react.uimanager.style.LogicalEdge
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [28])
class ThumbnailCornerRadiusTest {
    private val context: Context get() = RuntimeEnvironment.getApplication()

    @Before
    fun setUp() {
        ReactNativeFeatureFlagsForTests.setUp()
        DisplayMetricsHolder.initDisplayMetricsIfNotInitialized(context)
    }

    @Test
    fun readsNumericShorthandFromTheNativeImage() {
        val image = image()
        radius(image, BorderRadiusProp.BORDER_RADIUS, 20f)
        assertEquals(pixels(20f), ThumbnailCornerRadius.read(image), 0.001f)
    }

    @Test
    fun explicitZeroCornerDoesNotFallBackToShorthand() {
        val image = image()
        radius(image, BorderRadiusProp.BORDER_RADIUS, 20f)
        radius(image, BorderRadiusProp.BORDER_TOP_LEFT_RADIUS, 0f)
        assertEquals(0f, ThumbnailCornerRadius.read(image), 0f)
    }

    @Test
    fun logicalCornerDoesNotFallBackToShorthand() {
        val image = image()
        radius(image, BorderRadiusProp.BORDER_RADIUS, 20f)
        radius(image, BorderRadiusProp.BORDER_START_START_RADIUS, 0f)
        assertEquals(0f, ThumbnailCornerRadius.read(image), 0f)
    }

    @Test
    fun equalCornerOverridesRemainOutsideTheScalarShorthandScope() {
        val image = image()
        radius(image, BorderRadiusProp.BORDER_RADIUS, 20f)
        listOf(
            BorderRadiusProp.BORDER_TOP_LEFT_RADIUS,
            BorderRadiusProp.BORDER_TOP_RIGHT_RADIUS,
            BorderRadiusProp.BORDER_BOTTOM_LEFT_RADIUS,
            BorderRadiusProp.BORDER_BOTTOM_RIGHT_RADIUS,
        ).forEach { radius(image, it, 10f) }
        assertEquals(0f, ThumbnailCornerRadius.read(image), 0f)
    }

    @Test
    fun nativeRoundRectOutlineMustCoverTheImage() {
        val image = image()
        image.outlineProvider = object : ViewOutlineProvider() {
            override fun getOutline(view: View, outline: Outline) {
                outline.setRoundRect(0, 0, 100, 100, 20f)
            }
        }
        assertEquals(20f, ThumbnailCornerRadius.read(image), 0f)

        image.outlineProvider = object : ViewOutlineProvider() {
            override fun getOutline(view: View, outline: Outline) {
                outline.setRoundRect(20, 20, 80, 80, 20f)
            }
        }
        assertEquals(0f, ThumbnailCornerRadius.read(image), 0f)
    }

    @Test
    fun inheritsCoincidentClippingWrapper() {
        val image = image()
        wrapper(image, 100, 0, "hidden")
        assertEquals(pixels(20f), ThumbnailCornerRadius.read(image), 0.001f)
    }

    @Test
    fun skipsInsetAndNonClippingWrappers() {
        val inset = image()
        wrapper(inset, 140, 20, "hidden")
        assertEquals(0f, ThumbnailCornerRadius.read(inset), 0f)

        val visible = image()
        wrapper(visible, 100, 0, "visible")
        assertEquals(0f, ThumbnailCornerRadius.read(visible), 0f)
    }

    @Test
    fun skipsTransformedWrappers() {
        val image = image()
        wrapper(image, 100, 0, "hidden").rotation = 15f
        assertEquals(0f, ThumbnailCornerRadius.read(image), 0f)
    }

    @Test
    fun borderInsetIsNotMistakenForFullBoundsClipping() {
        val image = image()
        val parent = wrapper(image, 100, 0, "hidden")
        BackgroundStyleApplicator.setBorderWidth(parent, LogicalEdge.ALL, 10f)
        assertEquals(0f, ThumbnailCornerRadius.read(image), 0f)
    }

    @Test
    fun outerClippingCanIncreaseAnImagesRadius() {
        val image = image()
        radius(image, BorderRadiusProp.BORDER_RADIUS, 10f)
        wrapper(image, 100, 0, "hidden")
        assertEquals(pixels(20f), ThumbnailCornerRadius.read(image), 0.001f)
    }

    private fun image(): ImageView = ImageView(context).apply {
        // Exercise the RN fallback instead of receiving an already-resolved round-rect outline.
        outlineProvider = null
        clipToOutline = true
        layout(0, 0, 100, 100)
    }

    private fun wrapper(image: ImageView, size: Int, inset: Int, overflow: String): FrameLayout =
        OverflowLayout(context, overflow).apply {
            outlineProvider = null
            addView(image)
            layout(0, 0, size, size)
            image.layout(inset, inset, inset + 100, inset + 100)
            radius(this, BorderRadiusProp.BORDER_RADIUS, 20f)
        }

    private fun radius(view: View, corner: BorderRadiusProp, value: Float) {
        BackgroundStyleApplicator.setBorderRadius(view, corner, LengthPercentage(value, LengthPercentageType.POINT))
    }

    private fun pixels(value: Float): Float = value * context.resources.displayMetrics.density
}
