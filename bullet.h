#pragma once
#include "gameobject.h"

class Bullet : public GameObject {
    Q_OBJECT
public:
    Bullet(double x, double y, int direction, bool isFromPlayer, QObject *parent = nullptr);

    void update(double deltaTime) override;
    bool isFromPlayer() const { return m_isFromPlayer; }

private:
    bool m_isFromPlayer;
};