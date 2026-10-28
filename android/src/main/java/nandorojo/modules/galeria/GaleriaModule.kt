package nandorojo.modules.galeria

import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.ViewModelStoreOwner
import com.github.iielse.imageviewer.ImageViewerActionViewModel
import expo.modules.kotlin.functions.Queues
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class GaleriaModule : Module() {
    // Each module class must implement the definition function. The definition consists of components
    // that describes the module's functionality and behavior.
    // See https://docs.expo.dev/modules/module-api for more details about available components.
    override fun definition() = ModuleDefinition {
        // Sets the name of the module that JavaScript code will use to refer to the module. Takes a string as an argument.
        // Can be inferred from module's class name, but it's recommended to set it explicitly for clarity.
        // The module will be accessible from `requireNativeModule('Galeria')` in JavaScript.
        Name("Galeria")

        // Closes the open viewer, as the back button (`Galeria.dismiss()`).
        AsyncFunction("dismiss") {
            (appContext.currentActivity as? ViewModelStoreOwner)?.let {
                ViewModelProvider(it).get(ImageViewerActionViewModel::class.java).dismiss()
            }
        }.runOnQueue(Queues.MAIN)

        View(GaleriaOverlayView::class) {
            Prop("urls") { view: GaleriaOverlayView, urls: Array<String>? ->
                view.urls = urls
            }
        }

        // Enables the module to be used as a native view. Definition components that are accepted as part of
        // the view definition: Prop, Events.
        View(GaleriaView::class) {
            Events(
                "onIndexChange",
                "onLongPress",
                "onDismiss"
            )
            // Defines a setter for the `name` prop.
            Prop("theme") { view: GaleriaView, theme: Theme ->
                view.theme = theme
            }
            Prop("urls") { view: GaleriaView, urls: Array<String> ->
                view.urls = urls
            }
            Prop("mediaTypes") { view: GaleriaView, mediaTypes: Array<String> ->
                view.mediaTypes = mediaTypes
            }
            Prop("autoPlayVideo") { view: GaleriaView, autoPlayVideo: Boolean ->
                view.autoPlayVideo = autoPlayVideo
            }
            Prop("index") { view: GaleriaView, index: Int ->
                view.initialIndex = index
            }
            Prop("disableHiddenOriginalImage") { view: GaleriaView, disableHiddenOriginalImage: Boolean ->
                view.disableHiddenOriginalImage = disableHiddenOriginalImage
            }
            Prop("edgeToEdge") { view: GaleriaView, edgeToEdge: Boolean ->
                view.edgeToEdge = edgeToEdge
            }
            Prop("transitionOffsetY") { view: GaleriaView, transitionOffsetY: Int? ->
                view.transitionOffsetY = transitionOffsetY
            }
            Prop("transitionOffsetX") { view: GaleriaView, transitionOffsetX: Int? ->
                view.transitionOffsetX = transitionOffsetX
            }
        }
    }
}
