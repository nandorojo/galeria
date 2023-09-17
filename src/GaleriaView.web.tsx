import { useState, useId } from "react";

import { GaleriaViewProps } from "./Galeria.types";
import { unstable_createElement } from "react-native-web";
import { motion, useMotionValue } from "framer-motion";
import { Modal } from "react-native";

const Img = ((props) =>
  unstable_createElement(motion.img, props)) as typeof motion.img;

export default function GaleriaView({
  src,
  style,
  theme = "dark",
}: GaleriaViewProps) {
  const [open, setOpen] = useState(false);
  const id = useId();
  const isDragging = useMotionValue(false);
  return (
    <>
      <Img
        layoutId={id}
        src={src}
        style={style as object}
        onClick={() => {
          setOpen(true);
        }}
      />
      {/* don't even render the modal if it's false */}
      {open && (
        <Modal onRequestClose={() => setOpen(false)} transparent>
          <motion.div
            drag
            onDragStart={() => {
              isDragging.set(true);
            }}
            onDragEnd={() => {
              isDragging.set(false);
              setOpen(false);
            }}
            onClick={() => {
              if (!isDragging.get()) {
                // run on next tick to transition back
                setTimeout(() => setOpen(false));
              }
            }}
            style={{
              display: "flex",
              flex: 1,
              justifyContent: "center",
              backgroundColor: theme === "dark" ? "black" : "white",
              flexDirection: "column",
            }}
          >
            <Img
              loading="eager"
              layoutId={id}
              src={src}
              style={{
                width: "100%",
                height: "auto",
                display: "block",
                pointerEvents: "none",
              }}
            />
          </motion.div>
        </Modal>
      )}
    </>
  );
}
