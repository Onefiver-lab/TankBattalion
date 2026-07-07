#pragma once
#include "gameobject.h"

class Bullet : public GameObject {
    Q_OBJECT
    Q_PROPERTY(bool isFromPlayer READ isFromPlayer CONSTANT)

public:
    Bullet(double x, double y, int direction, bool isFromPlayer, int shooterId = 1, QObject *parent = nullptr);

    void update(double deltaTime) override;
    bool isFromPlayer() const { return m_isFromPlayer; }
    int shooterId() const { return m_shooterId; }

private:
    bool m_isFromPlayer;
    int m_shooterId; // 1代表玩家1，2代表玩家2，0代表敌军
};