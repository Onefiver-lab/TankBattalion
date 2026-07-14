cmake_minimum_required(VERSION 4.1.1)
set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")
set(CMAKE_CXX_MODULE_STD ON)

project(TankBattalion VERSION 0.1 LANGUAGES CXX)
set(QT_QML_GENERATE_QMLLS_INI ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2)
qt_standard_project_setup(REQUIRES 6.11)

qt_add_executable(appTankBattalion WIN32)

qt_add_qml_module(appTankBattalion
    URI TankBattalion
    VERSION 1.0
    SOURCES
        main.cpp
        gameobject.h       gameobject.cpp
        bullet.h           bullet.cpp
        gamecontroller.h   gamecontroller.cpp
        tank.h             tank.cpp
        mapmanager.h       mapmanager.cpp
        settingsmanager.h  settingsmanager.cpp
        savemanager.h      savemanager.cpp
    QML_FILES
        Main.qml
        BattleField.qml
        ControlHud.qml
        PauseOverlay.qml
        SettingsPanel.qml
        EndDialog.qml
        TankSprite.qml
        TileMapView.qml
        EnemySprite.qml
        BulletSprite.qml
)

target_compile_features(appTankBattalion PRIVATE cxx_std_23)
target_link_libraries(appTankBattalion
    PRIVATE
        Qt6::Quick
        Qt6::QuickControls2
)

set(CMAKE_INSTALL_PREFIX "/opt/${PROJECT_NAME}" CACHE PATH "Install path prefix" FORCE)
install(TARGETS appTankBattalion
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)