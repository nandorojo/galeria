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
 * Responsibilities:
 *   1. When [isAppearanceLightSystemBars] is non-null, present an edge-to-edge
 *      dialog with the system bars colored to match the light/dark theme.
 *      When null, fall through to the library's default dialog.
 *   2. Forward the dialog's onDismiss to [onDismissCallback], so the JS side
 *      can be notified when the viewer is dismissed (any dismissal mechanism:
 *      swipe-to-dismiss, system back button, programmatic dismiss).
 *   3. Forward lifecycle events to the gallery playback session.
 */
class EdgeToEdgeImageViewerDialogFragment(
    private val isAppearanceLightSystemBars: Boolean?,
    private val onResumeCallback: () -> Unit,
    private val onPauseCallback: () -> Unit,
    private val onDestroyCallback: () -> Unit,
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

    override fun onResume() {
        super.onResume()
        onResumeCallback()
    }

    override fun onPause() {
        onPauseCallback()
        super.onPause()
    }

    override fun onDestroyView() {
        onDestroyCallback()
        super.onDestroyView()
    }

    override fun onDismiss(dialog: DialogInterface) {
        super.onDismiss(dialog)
        onDismissCallback()
    }
}
