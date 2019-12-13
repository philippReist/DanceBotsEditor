import QtQuick 2.13
import dancebots.backend 1.0
import "../GuiStyle"

Rectangle{
  id: root
  anchors.top: (parent.isMotor || !parent.isFromBar) ? undefined : parent.bottom
  anchors.bottom: (parent.isMotor || !parent.isFromBar) ? parent.top : undefined
  // visible is disabled if a drag is active or if there is no primitive data
  // it is enabled under the above plus:
  //    - showData is triggered through a hover
  //    - the parent primitive is in a control box (!isFromBar) and enabled
  visible: !parent.dragActive && primitive && (parent.showData
           || (!parent.isFromBar && parent.enabled))
  color: Style.palette.prim_toolTipBackground
  width: parent.isMotor ? motorColumn.width : ledColumn.width
  height: parent.isMotor ? motorColumn.height : ledColumn.height
  radius: parent.radius

  property real padding: parent.height * Style.primitives.toolTipPadding
  property real fontSize: parent.height * Style.primitives.toolTipFontSize

  onVisibleChanged: {
    if(visible){
      update()
    }
  }

  function update(){
    // only update if visible
    if(visible){
      // only update relevant portion
      if(parent.isMotor){
        // doing this because there was an issue with property binding
        motorColumn.visible = true
        motorColumn.update()
      }else{
        // doing this because there was an issue with property binding
        ledColumn.visible = true
        ledColumn.update()
      }
    }
  }

  Column{
    id:motorColumn
    visible: false
    spacing: root.padding
    padding: root.padding
    function update(){
      // only update visible values
      if(motFreq.visible){
        motFreq.text = "Freq: " + primitive.frequency.toFixed(2)
      }
      if(velText.visible){
        var linDir = primitive.velocity >= 0 ? " Fwd" : " Bwd"
        var rotDir = primitive.velocity >= 0 ? " CCW" : " CW"
        switch(primitive.type){
        case MotorPrimitive.Type.Custom:
          velText.text = "Vel L: " + Math.abs(primitive.velocity) + linDir
          break;
        case MotorPrimitive.Type.Straight:
          velText.text = "Vel: " + Math.abs(primitive.velocity) + linDir
          break;
        case MotorPrimitive.Type.Spin:
          velText.text = "Vel: " + Math.abs(primitive.velocity) + rotDir
          break;
        case MotorPrimitive.Type.Twist:
        case MotorPrimitive.Type.BackAndForth:
          velText.text = "Amp: " + Math.abs(primitive.velocity)
          break;
        }
      }
      if(dirText.visible){
        if(primitive.type === MotorPrimitive.Type.BackAndForth){
          dirText.text = primitive.velocity >= 0 ? "Start: Fwd" : "Start: Bwd"
        }else{
          dirText.text = primitive.velocity >= 0 ? "Start: CCW" : "Start: CW"
        }
      }
      if(velRightText.visible){
        velRightText.text = primitive.velocityRight >= 0 ?
              "Vel R: " + Math.abs(primitive.velocityRight) + " Fwd"
            : "Vel R: " + Math.abs(primitive.velocityRight) + " Bwd"
      }
    }
    Text{
      id: motFreq
      visible: motorColumn.visible
        && primitive.type !== MotorPrimitive.Type.Spin
        && primitive.type !== MotorPrimitive.Type.Straight
        && primitive.type !== MotorPrimitive.Type.Custom
      font.pixelSize: root.fontSize
      color: Style.palette.prim_toolTipFont
    }
    Text{
      id: velText
      visible: motorColumn.visible
      font.pixelSize: root.fontSize
      color: Style.palette.prim_toolTipFont
    }
    Text{
      id: dirText
      visible: {motorColumn.visible
               && (primitive.type === MotorPrimitive.Type.Twist
               || primitive.type === MotorPrimitive.Type.BackAndForth)}
      font.pixelSize: root.fontSize
      color: Style.palette.prim_toolTipFont
    }
    Text{
      id: velRightText
      visible: {motorColumn.visible
               && primitive.type === MotorPrimitive.Type.Custom}
      font.pixelSize: root.fontSize
      color: Style.palette.prim_toolTipFont
    }
  }

  Column{
    id:ledColumn
    visible: false
    spacing: root.padding
    padding: root.padding

    function update(){
      if(ledFreqText.visible){
        ledFreqText.text = "Freq: " + primitive.frequency.toFixed(2)
      }
      if(ledRow.visible){
        ledRow.update()
      }
    }

    Text{
      id: ledFreqText
      visible: ledColumn.visible
        && primitive.type !== LEDPrimitive.Type.Constant
      text: "Freq: 1.00"
      font.pixelSize: root.fontSize
      color: Style.palette.prim_toolTipFont
    }

    Row{
      id: ledRow
      visible: { ledColumn.visible
        && primitive.type !== LEDPrimitive.Type.KnightRider
        && primitive.type !== LEDPrimitive.Type.Random
      }
      function update(){
        for(var i = 0; i < primitive.leds.length; i++){
          if(primitive.leds[i]){
            ledRepeater.itemAt(i).color =  Style.palette.prim_toolTipLEDon
          }else{
            ledRepeater.itemAt(i).color =  Style.palette.prim_toolTipLEDoff
          }
        }
      }

      Repeater{
        id: ledRepeater
        model: 8
        delegate: Rectangle{
          width: Style.primitives.ledToolTipLEDSize * root.parent.height
          height: width
          radius: width / 2
          color: Style.palette.prim_toolTipLEDoff
        }
      }
    }
  }
}