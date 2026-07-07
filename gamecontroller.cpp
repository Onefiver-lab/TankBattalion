#include "gamecontroller.h"
#include <QDebug>

GameController::GameController(QObject *parent) : QObject(parent), m_playerTank(nullptr) {
    m_gameTimer = new QTimer(this);
    connect(m_gameTimer, &QTimer::timeout, this, &GameController::gameLoop);

    m_mapManager = new MapManager(this); // 实例化地图
    m_playerTank = new Tank(380, 500, true, this);
}

GameController::~GameController() {
    qDeleteAll(m_bulletList);
    qDeleteAll(m_enemyList);
}

void GameController::startGame() {
    m_elapsedTimer.start();

    m_mapManager->loadDefaultMap();
    qDeleteAll(m_enemyList);
    m_enemyList.clear();
    spawnEnemies();

    m_gameTimer->start(16); // ~60 FPS
    qDebug() << "游戏全面开始！";
}

void GameController::pauseGame() {
    m_gameTimer->stop();
}

void GameController::spawnEnemies() {
    m_enemyList.append(new Tank(100, 50, false, this));
    m_enemyList.append(new Tank(400, 50, false, this));
    m_enemyList.append(new Tank(700, 50, false, this));
    emit enemiesChanged();
}

void GameController::handlePlayerMove(int direction, bool moving) {
    if (m_playerTank && m_playerTank->isActive()) {
        m_playerTank->setDirection(direction);
        m_playerTank->setMoving(moving);
    }
}

void GameController::handlePlayerFire() {
    if (m_playerTank && m_playerTank->isActive()) {
        Bullet *b = m_playerTank->fire();
        if (b) {
            m_bulletList.append(b);
            emit bulletsChanged();
        }
    }
}

void GameController::spawnPlayerBullet(double x, double y, int direction) {
    Bullet *newBullet = new Bullet(x, y, direction, true, this);
    m_bulletList.append(newBullet);
    emit bulletsChanged();
}

void GameController::gameLoop() {
    double deltaTime = m_elapsedTimer.restart() / 1000.0;
    if (deltaTime > 0.05) deltaTime = 0.05;

    if (m_playerTank && m_playerTank->isActive()) {
        QRectF oldBox = m_playerTank->boundingBox();
        m_playerTank->update(deltaTime);
        if (m_mapManager->checkCollision(m_playerTank->boundingBox())) {
            m_playerTank->setX(oldBox.x());
            m_playerTank->setY(oldBox.y());
        }
    }

    bool enemyFired = false;
    for (Tank *enemy : m_enemyList) {
        if (enemy->isActive()) {
            QRectF oldEnemyBox = enemy->boundingBox();
            enemy->update(deltaTime);
            if (m_mapManager->checkCollision(enemy->boundingBox())) {
                enemy->setX(oldEnemyBox.x());
                enemy->setY(oldEnemyBox.y());
            }

            if (rand() % 100 < 2) {
                Bullet *b = enemy->fire();
                if (b) {
                    m_bulletList.append(b);
                    enemyFired = true;
                }
            }
        }
    }
    if (enemyFired) {
        emit bulletsChanged();
    }

    for (Bullet *bullet : m_bulletList) {
        bullet->update(deltaTime);
    }

    checkCollisions();

    cleanUpDestroyedObjects();

    emit enemiesChanged();
    emit bulletsChanged();
}

void GameController::checkCollisions() {
    for (Bullet *bullet : m_bulletList) {
        if (!bullet->isActive()) continue;

        if (m_mapManager->handleBulletHit(bullet->boundingBox())) {
            bullet->setActive(false);
            continue;
        }

        if (bullet->isFromPlayer()) {
            for (Tank *enemy : m_enemyList) {
                if (enemy->isActive() && bullet->boundingBox().intersects(enemy->boundingBox())) {
                    bullet->setActive(false);
                    enemy->takeDamage(1);
                    break;
                }
            }
        } else {
            if (m_playerTank && m_playerTank->isActive()) {
                if (bullet->boundingBox().intersects(m_playerTank->boundingBox())) {
                    bullet->setActive(false);
                    m_playerTank->takeDamage(1);
                    if (!m_playerTank->isActive()) {
                        emit gameOver();
                        m_gameTimer->stop();
                    }
                }
            }
        }
    }
}

void GameController::cleanUpDestroyedObjects() {
    bool bChanged = false;
    auto bit = m_bulletList.begin();
    while (bit != m_bulletList.end()) {
        if (!(*bit)->isActive()) {
            (*bit)->deleteLater();
            bit = m_bulletList.erase(bit);
            bChanged = true;
        } else {
            ++bit;
        }
    }
    if (bChanged) emit bulletsChanged();

    bool eChanged = false;
    auto tit = m_enemyList.begin();
    while (tit != m_enemyList.end()) {
        if (!(*tit)->isActive()) {
            (*tit)->deleteLater();
            tit = m_enemyList.erase(tit);
            eChanged = true;
        } else {
            ++tit;
        }
    }
    if (eChanged) emit enemiesChanged();
}

QList<QObject*> GameController::bullets() const {
    QList<QObject*> list;
    for (auto b : m_bulletList) list.append(b);
    return list;
}

QList<QObject*> GameController::enemies() const {
    QList<QObject*> list;
    for (auto e : m_enemyList) list.append(e);
    return list;
}