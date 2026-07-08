#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "gamecontroller.h"
#include "gameobject.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    qmlRegisterType<GameController>("com.game.tank", 1, 0, "GameController");
    qmlRegisterUncreatableType<GameObject>("com.game.tank", 1, 0, "GameObject", "不能在QML中直接实例化基类");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/qt/qml/TankBattalion/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}