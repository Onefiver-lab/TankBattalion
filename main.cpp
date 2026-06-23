#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "gamecontroller.h"
#include "gameobject.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    qmlRegisterType<GameController>("com.game.tank", 1, 0, "GameController");

    qmlRegisterUncreatableType<GameObject>("com.game.tank", 1, 0, "GameObject",
                                           "Cannot create instance of Base class GameObject");

const QUrl url(QStringLiteral("qrc:/qt/qml/TankBattalion/Main.qml"));    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}