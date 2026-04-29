package nandorojo.modules.galeria

import android.app.Dialog
import android.content.DialogInterface
import android.os.Bundle
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsControllerCompat
import com.github.iielse.imageviewer.ImageViewerDialogFragment

/**
 * Subclass of [ImageViewerDialogFragment] used by Galeria.
 *
 * Two responsibilities:
 *   1. When [isAppearanceLightSystemBars] is non-null, present an edge-to-edge
 *      dialog with the system bars colored to match the light/dark theme.
 *      When null, fall through to the library's default dialog.
 *   2. Forward the dialog's onDismiss to [onDismissCallback], so the JS side
 *      can be notified when the viewer is dismissed (any dismissal mechanism:
 *      swipe-to-dismiss, system back button, programmatic dismiss).
 */
class EdgeToEdgeImageViewerDialogFragment(
    private val isAppearanceLightSystemBars: Boolean?,
    private val onDismissCallback: () -> Unit,
) : ImageViewerDialogFragment() {

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        if (isAppearanceLightSystemBars == null) {
            return super.onCreateDialog(savedInstanceState)
        }
        return Dialog(requireActivity(), R.style.Theme_FullScreenDialog).apply {
            setCanceledOnTouchOutside(true)

            window?.let {
                WindowCompat.setDecorFitsSystemWindows(it, false)

                WindowInsetsControllerCompat(it, it.decorView).run {
                    isAppearanceLightStatusBars = isAppearanceLightSystemBars
                    isAppearanceLightNavigationBars = isAppearanceLightSystemBars
                }
            }
        }
    }

    override fun onDismiss(dialog: DialogInterface) {
        super.onDismiss(dialog)
        onDismissCallback()
    }
}
