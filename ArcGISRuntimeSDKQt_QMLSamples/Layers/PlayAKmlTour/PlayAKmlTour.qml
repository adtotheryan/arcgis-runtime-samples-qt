// [WriteFile Name=PlayAKmlTour, Category=Layers]
// [Legal]
// Copyright 2019 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// [Legal]

import QtQuick 2.6
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Esri.ArcGISRuntime 100.6
import Esri.ArcGISExtras 1.1

Rectangle {
    id: rootRectangle
    clip: true
    width: 800
    height: 600

    readonly property url dataPath: System.userHomePath +  "/ArcGIS/Runtime/Data/kml"

    SceneView {
        id: sceneView
        anchors.fill: parent

        Scene {
            id: scene
            BasemapImagery {}

            Surface {
                ArcGISTiledElevationSource {
                    url: "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer"
                }
            }

            KmlLayer {
                id: kmlLayer
               dataset: KmlDataset {
                   id: kmlDataset
                   url: dataPath + "/Esri_tour.kmz"

                   onLoadStatusChanged: {
                       console.log("load status before: " + loadStatus);
                       if (loadStatus !== Enums.LoadStatusLoaded)
                           return;

                       console.log("load status after: " + loadStatus);


                       var kmlTour = findFirstKMLTour(kmlDataset.rootNodes)
                       kmlTour.tourStatusChanged.connect(function() {
                           switch(kmlTour.tourStatus) {
                           case Enums.KmlTourStatusCompleted:
                           case Enums.KmlTourStatusInitialized:
                               playButton.enabled = true;
                               pauseButton.enabled = false;
                               break;
                           case Enums.KmlTourStatusPaused:
                               playButton.enabled = true;
                               pauseButton.enabled = false;
                               resetButton.enabled = true;
                               break;
                           case Enums.KmlTourStatusPlaying:
                               playButton.enabled = false;
                               pauseButton.enabled = true;
                               resetButton.enabled = true;
                               break;
                           }
                       });

                       kmlTourController.tour = kmlTour;

                       if (kmlTour !== null) {
                           playButton.enabled = true;
                       }

                   }
                }
            }

            KmlTourController {
                id: kmlTourController
            }
        }

        Rectangle {
            id: buttonBackground
            anchors {
                left: parent.left
                top: parent.top
                margins: 3
            }
            width: childrenRect.width
            height: childrenRect.height
            color: "#000000"
            opacity: .75
            radius: 5

            RowLayout {
                spacing: 0
                Button {
                    id: playButton
                    text: qsTr("Play")
                    Layout.margins: 2
                    enabled: false
                    onClicked: kmlTourController.play();
                }

                Button {
                    id: pauseButton
                    text: qsTr("Pause")
                    Layout.margins: 2
                    enabled: false
                    onClicked: kmlTourController.pause();
                }

                Button {
                    id: resetButton
                    text: qsTr("Reset")
                    Layout.margins: 2
                    enabled: false
                    onClicked: kmlTourController.reset();
                }
            }
        }
    }

    function findFirstKMLTour(nodes) {
        console.log("length: " + nodes.length);
        for (var i = 0; i < nodes.length; i++) {
            let node = nodes[i];
            console.log("name: " + node.name);
            console.log("node type: " + node.kmlNodeType);
            console.log("o type: " + node.objectType);
            if (node.kmlNodeType === Enums.KmlNodeTypeKmlTour)
                return node;
            else if (node instanceof KmlContainer)
                return findFirstKMLTour(node.childNodes);
//                return findFirstKMLTourFromListModel(node.childNodesListModel);
        }
        return null;
    }

    function findFirstKMLTourFromListModel(nodes) {

        nodes.forEach(function(node) {
            console.log("name: " + node.name);
            console.log("node type: " + node.kmlNodeType);
            console.log(node.childNodes.length);
            console.log("o type: " + node.objectType);
            if (node.kmlNodeType === Enums.KmlNodeTypeKmlTour)
                return node;
            else if( node.kmlNodeType !== Enums.KmlNodeTypeKmlTour)
                return findFirstKMLTourFromListModel(node.childrenNodesListModel);
        });
        return null;
    }
}
