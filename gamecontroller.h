#pragma once
#include <QObject>
#include <QTimer>
#include <QElapsedTimer>
#include <QList>
#include "bullet.h"

class GameController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QList<QObject*> bullets READ bullets)

public:
    explicit GameController(QObject *parent = nullptr);
    ~GameController();

    Q_INVOKABLE void startGame();
    Q_INVOKABLE void pauseGame();
    Q_INVOKABLE void spawnPlayerBullet(double x, double y, int direction);

    QList<QObject*> bullets() const;

signals:
    void gameOver();
private slots:
    void gameLoop();

private:
    void checkCollisions();
    void cleanUpDestroyedObjects();

    QTimer *m_gameTimer;
    QElapsedTimer m_elapsedTimer;
    QList<Bullet*> m_bulletList;
};