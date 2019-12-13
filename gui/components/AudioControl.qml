import QtQuick 2.6
import QtQuick.Controls 2.0
import dancebots.backend 1.0
import QtGraphicalEffects 1.13
import "../GuiStyle"

Item {
  id: root
  property alias sliderPosition: songPositionSlider.visualPosition

  height: songPositionSlider.height + playControlItem.height
          + appWindow.guiMargin

  property int sliderHeight: width * Style.audioControl.sliderHeight

  enabled: false

  Connections{
    target: backend
    onDoneLoading:{
      if(result){
        enabled = true
        backend.audioPlayer.setNotifyInterval(30);
        songPositionSlider.value = 0
        songPositionSlider.to =
          backend.getAudioLengthInFrames() / backend.getSampleRate() * 1000;
      }
    }
  }

  Connections{
    target: backend.audioPlayer
    onNotify:{
      // set slider to current position in music,
      // but only if user is not dragging slider at the moment:
      if(!songPositionSlider.pressed){
        songPositionSlider.value = currentPosMS
      }
    }
  }

  ScalableSlider{
    id: songPositionSlider
    from: 0.0
    to: 1.0
    width: root.width
    height: sliderHeight
    focusPolicy: Qt.NoFocus

    onPressedChanged:{
      appWindow.grabFocus()
      if(!pressed){
        backend.audioPlayer.seek(value)
      }
    }
    sliderBarSize: Style.primitiveControl.sliderBarSize
    backgroundColor: Style.palette.ac_songPositionSliderBarEnabled
    backgroundDisabledColor: Style.palette.ac_songPositionSliderBarDisabled
    backgroundActiveColor: Style.palette.ac_songPositionSliderBarActivePartEnabled
    backgroundActiveDisabledColor: Style.palette.ac_songPositionSliderBarActivePartDisabled
    handleColor: Style.palette.ac_songPositionSliderHandleEnabled
    handleDisabledColor: Style.palette.ac_songPositionSliderHandleDisabled
  }

  Item{
    id: playControlItem
    width: parent.width - 2 * appWindow.guiMargin
    anchors.top: songPositionSlider.bottom
    anchors.topMargin: appWindow.guiMargin
    anchors.horizontalCenter: root.horizontalCenter
    height: sliderHeight * Style.audioControl.buttonHeight

    Row{
      id: buttonRow
      spacing: Style.audioControl.buttonSpacing * root.sliderHeight
      anchors.verticalCenter: playControlItem.verticalCenter
      anchors.horizontalCenter: playControlItem.horizontalCenter
      Button
      {
        id: playButton
        focusPolicy: Qt.NoFocus
        width: playControlItem.height
        height: playControlItem.height
        property color buttonColor: enabled ? Style.palette.ac_buttonEnabled
                                            : Style.palette.ac_buttonDisabled

        contentItem: Item{
          height: parent.height
          width: parent.width
          Image{
            id: playImage
            anchors.centerIn: parent
            source: "../icons/play.svg"
            sourceSize.height: parent.height * Style.audioControl.buttonIconSize
            antialiasing: true
            visible: false
          }

          ColorOverlay{
            anchors.fill: playImage
            source: playImage
            color: parent.enabled ? Style.palette.ac_buttonIconEnabled
                                  : Style.palette.ac_buttonIconDisabled
            antialiasing: true
            visible: !backend.audioPlayer.isPlaying
          }

          Image{
            id: pauseImage
            anchors.centerIn: parent
            source: "../icons/pause.svg"
            sourceSize.height: parent.height * Style.audioControl.buttonIconSize
            antialiasing: true
            visible: false
          }

          ColorOverlay{
            anchors.fill: pauseImage
            source: pauseImage
            color: parent.enabled ? Style.palette.ac_buttonIconEnabled
                                  : Style.palette.ac_buttonIconDisabled
            antialiasing: true
            visible: backend.audioPlayer.isPlaying
          }
        }

        background: Rectangle{
          anchors.fill: parent
          radius: parent.height / 2
          color: parent.pressed ? Style.palette.ac_buttonPressed
                 : parent.buttonColor
        }

        onPressed: appWindow.grabFocus()
        onClicked:
        {
          backend.audioPlayer.togglePlay()
        }
      }
      Button
      {
        id: stopButton
        focusPolicy: Qt.NoFocus
        width: playControlItem.height
        height: playControlItem.height
        property color buttonColor: enabled ? Style.palette.ac_buttonEnabled
                                            : Style.palette.ac_buttonDisabled

        contentItem: Item{
          height: parent.height
          width: parent.width
          Image{
            id: stopImage
            anchors.centerIn: parent
            source: "../icons/stop.svg"
            sourceSize.height: parent.height * Style.audioControl.buttonIconSize
            antialiasing: true
            visible: false
          }

          ColorOverlay{
            anchors.fill: stopImage
            source: stopImage
            color: parent.enabled ? Style.palette.ac_buttonIconEnabled
                                  : Style.palette.ac_buttonIconDisabled
            antialiasing: true
          }
        }

        background: Rectangle{
          anchors.fill: parent
          radius: parent.height / 2
          color: parent.pressed ? Style.palette.ac_buttonPressed
                 : parent.buttonColor
        }

        onPressed: appWindow.grabFocus()
        onClicked:
        {
          backend.audioPlayer.stop()
        }
      }
    }

    Text{
      anchors.left: playControlItem.left
      anchors.verticalCenter: playControlItem.verticalCenter
      property var minutes: Math.floor(songPositionSlider.value / 60000.0)
      property var seconds: (songPositionSlider.value / 1000.0 - minutes * 60.0)
      property var secondString: "0" + seconds.toFixed(1)
      text: {
        // cut off zero front pad in case more than 10 seconds
        secondString.length > 4 ?
              minutes.toFixed(0) + ":" + secondString.substr(1)
            : minutes.toFixed(0) + ":" + secondString
      }
      font.pixelSize: Style.audioControl.timerFontSize
                      * root.sliderHeight
      color: enabled ? Style.palette.ac_timerFontEnabled
                     : Style.palette.ac_timerFontDisabled
    }

    Row{
      id: volumeRow
      anchors.right: playControlItem.right
      anchors.verticalCenter: playControlItem.verticalCenter
      spacing: appWindow.guiMargin
      Connections{
        target: backend.audioPlayer
        onVolumeAvailable:{
          volumeSlider.value = backend.audioPlayer.getCurrentLogVolume()
        }
      }

      Item{
        width: speakerImage.width
        height: speakerImage.height
        anchors.verticalCenter: parent.verticalCenter
        Image{
          id: speakerImage
          source: "../icons/volume.svg"
          anchors.verticalCenter: parent.verticalCenter
          width: root.sliderHeight * Style.audioControl.volumeIconScale
          height: width
          visible: false
        }

        ColorOverlay{
          anchors.fill: speakerImage
          source: speakerImage
          color: root.enabled ? Style.palette.ac_volumeSliderIconColorEnabled
                              : Style.palette.ac_volumeSliderIconColorDisabled
          antialiasing: true
        }
      }

      ScalableSlider{
        id: volumeSlider
        from: 0.0
        to: 1.0
        value: 1.0
        anchors.verticalCenter: parent.verticalCenter
        height: root.sliderHeight * Style.audioControl.volumeSliderHeight
        width: root.width * Style.audioControl.volumeSliderWidth
        focusPolicy: Qt.NoFocus
        live: true
        onPressedChanged: appWindow.grabFocus()
        onValueChanged: backend.audioPlayer.setVolume(value)

        sliderBarSize: Style.audioControl.volmeSliderBarSize
        backgroundColor: Style.palette.ac_volumeSliderBarEnabled
        backgroundDisabledColor: Style.palette.ac_volumeSliderBarDisabled
        backgroundActiveColor: Style.palette.ac_volumeSliderBarActivePartEnabled
        backgroundActiveDisabledColor: Style.palette.ac_volumeSliderBarActivePartDisabled
        handleColor: Style.palette.ac_volumeSliderHandleEnabled
        handleDisabledColor: Style.palette.ac_volumeSliderHandleDisabled
      }
    }
  } // play control item
}