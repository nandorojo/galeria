package nandorojo.modules.galeria;

import android.content.Context;
import android.widget.FrameLayout;
import com.facebook.react.uimanager.ReactOverflowView;

// Java implements the same getter across RN's Java-interface and Kotlin-property versions.
final class OverflowLayout extends FrameLayout implements ReactOverflowView {
  private final String overflow;

  OverflowLayout(Context context, String overflow) {
    super(context);
    this.overflow = overflow;
  }

  @Override
  public String getOverflow() {
    return overflow;
  }
}
