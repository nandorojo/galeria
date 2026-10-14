package nandorojo.modules.galeria

import android.graphics.Outline
import android.os.Build
import android.view.View
import com.facebook.react.uimanager.BackgroundStyleApplicator
import com.facebook.react.uimanager.LengthPercentage
import com.facebook.react.uimanager.LengthPercentageType
import com.facebook.react.uimanager.style.BorderRadiusProp
import kotlin.math.min

/** Read uniform circular rounding from the rendered thumbnail, including custom components. */
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
        var current: View? = image
        while (current != null) {
            val outline = Outline()
            current.outlineProvider?.getOutline(current, outline)
            if (Build.VERSION.SDK_INT >= 24 && outline.radius > 0f && outline.radius.isFinite()) {
                return min(outline.radius, min(current.width, current.height) / 2f)
            }

            val radius = BackgroundStyleApplicator.getBorderRadius(current, BorderRadiusProp.BORDER_RADIUS)
            if (radius?.type == LengthPercentageType.POINT) {
                val result = if (resolve.parameterTypes.size == 1) resolve.invoke(radius, 1f)
                    else resolve.invoke(radius, 1f, 1f)
                val pixels = ((horizontal?.invoke(result) ?: result) as Number).toFloat() *
                    current.resources.displayMetrics.density
                if (pixels.isFinite() && pixels > 0f) {
                    return min(pixels, min(current.width, current.height) / 2f)
                }
            }

            if (current is GaleriaView) break
            current = current.parent as? View
        }
        return 0f
    }
}
