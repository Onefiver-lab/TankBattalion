

#pragma once
#include <QObject>
#include <QTimer>
#include <QElapsedTimer>
#include <QList>
#include "bullet.h"
#include "tank.h"

class GameController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QList<QObject*> bullets READ bullets NOTIFY bulletsChanged)
    Q_PROPERTY(QList<QObject*> enemies READ enemies NOTIFY enemiesChanged)
    Q_PROPERTY(Tank* player READ player CONSTANT)

public:
    explicit GameController(QObject *parent = nullptr);
    ~GameController();

    Q_INVOKABLE void startGame();
    Q_INVOKABLE void pauseGame();
    Q_INVOKABLE void spawnPlayerBullet(double x, double y, int direction);
    Q_INVOKABLE void handlePlayerMove(int direction, bool moving);
    Q_INVOKABLE void handlePlayerFire();

    QList<QObject*> bullets() const;
    QList<QObject*> enemies() const;
    Tank* player() const { return m_playerTank; }

signals:
    void gameOver();
    void bulletsChanged();
    void enemiesChanged();

private slots:
    void gameLoop();

private:
    void spawnEnemies();
    void checkCollisions();
    void cleanUpDestroyedObjects();

    QTimer *m_gameTimer;
    QElapsedTimer m_elapsedTimer;

    QList<Bullet*> m_bulletList;
    QList<Tank*> m_enemyList;
    Tank *m_playerTank;
};