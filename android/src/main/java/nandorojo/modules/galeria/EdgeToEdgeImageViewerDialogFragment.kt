package nandorojo.modules.galeria

import android.app.Dialog
import android.os.Bundle
import androidx.core.view.WindowCompat
import com.github.iielse.imageviewer.ImageViewerDialogFragment

class EdgeToEdgeImageViewerDialogFragment : ImageViewerDialogFragment() {

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        return Dialog(requireActivity(), R.style.Theme_FullScreenDialog).apply {
            setCanceledOnTouchOutside(true)

            window?.let {
                WindowCompat.setDecorFitsSystemWindows(it, false)
            }
        }
    }
}
