// system window component - to be used in morphic handlers

defineClass Window morph label closeBtn resizer border color clientArea clientColor scale shadow

to window label {
  window = (new 'Window')
  initialize window label
  return window
}

method morph Window {return morph}
method border Window {return border}
method clientArea Window {return clientArea}
method clientColor Window {return clientColor}
method labelString Window {return (text label)}

method initialize Window labelString {
  pe = (findProjectEditor)
  scale = (global 'scale')
  border = (scale * 5)
  color = (color pe 'blueGray' 850)
  clientColor = (color pe 'blueGray' 50)
  morph = (newMorph this)
  setGrabRule morph 'handle'
  setTransparentTouch morph false // optimization
  label = (newText (localized labelString) 'Arial Bold' (scale * 12) clientColor)
  addPart morph (morph label)
  closeBtn = (pushButton 'X' color (action 'destroy' (morph this)))
  addPart morph (morph closeBtn)
  resizer = (resizeHandle this)
}

method updateScale Window {
  scale = (global 'scale')
  border = (scale * 5)
  setFont label nil (scale * 12)
  removePart morph (morph closeBtn)
  closeBtn = (pushButton 'X' color (action 'destroy' (morph this)))
  addPart morph (morph closeBtn)
}

method fixLayout Window {
  labelSize = (+ (height (morph label)) border)
  clientArea = (rect (+ (left morph) border) (+ (top morph) labelSize border) (- (width morph) (border * 2)) ((height morph) - (+ labelSize (border * 2))))
  setPosition (morph label) (+ (left morph) (10 * (global 'scale'))) (+ (top morph) border)
  setTop (morph closeBtn) (+ (top morph) border)
  setRight (morph closeBtn) ((right morph) - border)
  setRight (morph resizer) (right clientArea)
  setBottom (morph resizer) (bottom clientArea)
  addPart morph (morph resizer) // bring to front
}

method redraw Window {
  w = (width morph)
  h = (height morph)
  bm = (newBitmap w h)
  fillRoundedRect (newShapeMaker bm) (rect 0 0 w h) (scale * 4) color 0 (lighter color 20)
  setCostume morph bm
}

method redrawShadow Window {
  if (isNil shadow) {return}
  w = (width morph)
  h = (height morph)
  radius = (4 * scale)
  off = (0 - (scale * 5))
  bm = (newBitmap w h)
  fillRoundedRect (newShapeMaker bm) (rect 0 0 w h) radius (gray 0)
  fillRect bm (transparent) off off w h
  setCostume shadow bm
}

method addShadow Window {
  shadow = (newMorph)
  setAlpha shadow 128
  off = (scale * 5)
  setPosition shadow (+ off (left morph)) (+ off (top morph))
  redrawShadow this
  addPart morph shadow
}

method setLabelString Window aString {
  setText label (localized aString)
  redraw label
  fixLayout this
}

method spaceBoundedBy Window max percent total {
  // let the user specify a dynamic space bounded by a percentage of the given total
  // and either a maximum unscaled size, or an Action
  if (isNumber max) {
    ceil = (scale * max)
  } else {
    ceil = (call max)
  }
  return (min ceil ((percent * total) / 100))
}

method titleBarWidth Window {
  return (+ (width (morph label)) (width (morph closeBtn)) (4 * border))
}

// serialization

method preSerialize Window {
  setCostume morph nil
  clearCostumes closeBtn
  clearCostumes resizer
}

method postSerialize Window {
  drawLabelCostumes closeBtn 'X' color
  drawResizeCostumes resizer
}
