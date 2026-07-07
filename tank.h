#pragma once
#include "gameobject.h"

class Tank : public GameObject {
    Q_OBJECT
    Q_PROPERTY(bool isMoving READ isMoving WRITE setMoving NOTIFY movingChanged)
    Q_PROPERTY(int ammo READ ammo WRITE setAmmo NOTIFY ammoChanged)
    Q_PROPERTY(int hp READ hp NOTIFY hpChanged)
    Q_PROPERTY(int maxHp READ maxHp CONSTANT)

public:
    Tank(double x, double y, bool isPlayer, int playerId = 0, QObject *parent = nullptr);

    bool isPlayer() const { return m_isPlayer; }
    int playerId() const { return m_playerId; }

    bool isMoving() const { return m_isMoving; }
    void setMoving(bool moving) { if (m_isMoving != moving) { m_isMoving = moving; emit movingChanged(); } }

    int ammo() const { return m_ammo; }
    void setAmmo(int ammo);

    int hp() const { return m_hp; }
    int maxHp() const { return m_maxHp; }
    void takeDamage(int amount);

    class Bullet* fire();
    void update(double deltaTime) override;

signals:
    void movingChanged();
    void ammoChanged();
    void hpChanged();

private:
    void updateAI(double deltaTime);

    bool m_isPlayer;
    int m_playerId;
    bool m_isMoving;
    int m_ammo;
    int m_hp;
    int m_maxHp;

    double m_aiDecisionTimer;
    double m_aiFireTimer;
};