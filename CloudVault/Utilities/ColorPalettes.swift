//
//  ColorPalettes.swift
//  CloudVault
//
//  Created by Chris Schofield on 27/02/2021.
//

import Foundation
import DynamicColor

let bluePalette = DynamicGradient(colors: [
  DynamicColor(hexString: "#84A9FF"),
  DynamicColor(hexString: "#6690FF"),
  DynamicColor(hexString: "#3366FF"),
  DynamicColor(hexString: "#254EDB"),
  DynamicColor(hexString: "#1939B7")
])

let greenPalette = DynamicGradient(colors: [
  DynamicColor(hexString: "#81ED87"),
  DynamicColor(hexString: "#5EDC72"),
  DynamicColor(hexString: "#2FC655"),
  DynamicColor(hexString: "#22AA51"),
  DynamicColor(hexString: "#178E4C")
])

let yellowPalette = DynamicGradient(colors: [
  DynamicColor(hexString: "#FFF57A"),
  DynamicColor(hexString: "#FFF259"),
  DynamicColor(hexString: "#FFEC23"),
  DynamicColor(hexString: "#DBC819"),
  DynamicColor(hexString: "#B7A611")
])

let orangePalette = DynamicGradient(colors: [
  DynamicColor(hexString: "#FFC47A"),
  DynamicColor(hexString: "#FFAC59"),
  DynamicColor(hexString: "#ff8523"),
  DynamicColor(hexString: "#DB6519"),
  DynamicColor(hexString: "#B74911")
])

let redPalette = DynamicGradient(colors: [
  DynamicColor(hexString: "#FFAA87"),
  DynamicColor(hexString: "#FF8969"),
  DynamicColor(hexString: "#FF5238"),
  DynamicColor(hexString: "#DB3228"),
  DynamicColor(hexString: "#B71C20")
])

let pinkPalette = DynamicGradient(colors: [
  DynamicColor(hexString: "#F98EE5"),
  DynamicColor(hexString: "#F471E6"),
  DynamicColor(hexString: "#ed44ea"),
  DynamicColor(hexString: "#C131CB"),
  DynamicColor(hexString: "#9522AA")
])

let purplePalette = DynamicGradient(colors: [
  DynamicColor(hexString: "#D08EF9"),
  DynamicColor(hexString: "#BA71F4"),
  DynamicColor(hexString: "#9a44ed"),
  DynamicColor(hexString: "#7831CB"),
  DynamicColor(hexString: "#5922AA")
])

func resolvePalette(_ paletteIndex: Int) -> DynamicGradient? {
  switch paletteIndex {
  case 0: return bluePalette
  case 1: return greenPalette
  case 2: return yellowPalette
  case 3: return orangePalette
  case 4: return redPalette
  case 5: return pinkPalette
  case 6: return purplePalette
  default: return nil
  }
}

func colorRotator(_ index: Int) -> String {
  let paletteIndex = index % 7
  let level = index - paletteIndex / 7 % 10
  let palette = resolvePalette(paletteIndex)!
  return palette.pickColorAt(scale: CGFloat(level) / 10).toHexString()
}
