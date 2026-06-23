#include "gamecontroller.h"
#include <QDebug>

GameController::GameController(QObject *parent) : QObject(parent) {
    m_gameTimer = new QTimer(this);
    connect(m_gameTimer, &QTimer::timeout, this, &GameController::gameLoop);
}

GameController::~GameController() {
    qDeleteAll(m_bulletList);
}

void GameController::startGame() {
    m_elapsedTimer.start();
    m_gameTimer->start(16);
    qDebug() << "游戏开始...";
}

void GameController::pauseGame() {
    m_gameTimer->stop();
}

void GameController::spawnPlayerBullet(double x, double y, int direction) {
    Bullet *newBullet = new Bullet(x, y, direction, true, this);
    m_bulletList.append(newBullet);
}

void GameController::gameLoop() {
    double deltaTime = m_elapsedTimer.restart() / 1000.0;
    if (deltaTime > 0.05) deltaTime = 0.05;

    for (Bullet *bullet : m_bulletList) {
        bullet->update(deltaTime);
    }

    checkCollisions();
    cleanUpDestroyedObjects();
}

void GameController::checkCollisions() {
    for (int i = 0; i < m_bulletList.size(); ++i) {
        for (int j = i + 1; j < m_bulletList.size(); ++j) {
            Bullet *b1 = m_bulletList[i];
            Bullet *b2 = m_bulletList[j];

            if (b1->isActive() && b2->isActive() && b1->isFromPlayer() != b2->isFromPlayer()) {
                if (b1->boundingBox().intersects(b2->boundingBox())) {
                    b1->setActive(false);
                    b2->setActive(false);
                }
            }
        }
    }
}

void GameController::cleanUpDestroyedObjects() {
    auto it = m_bulletList.begin();
    while (it != m_bulletList.end()) {
        if (!(*it)->isActive()) {
            (*it)->deleteLater();
            it = m_bulletList.erase(it);
        } else {
            ++it;
        }
    }
}

QList<QObject*> GameController::bullets() const {
    QList<QObject*> list;
    for (auto b : m_bulletList) {
        list.append(b);
    }
    return list;
}