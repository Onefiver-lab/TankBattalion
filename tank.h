#pragma once
#include "gameobject.h"

class Tank : public GameObject {
    Q_OBJECT
    Q_PROPERTY(int hp READ hp NOTIFY hpChanged)
    Q_PROPERTY(int maxHp READ maxHp CONSTANT)
    Q_PROPERTY(bool isPlayer READ isPlayer CONSTANT)

public:
    Tank(double x, double y, bool isPlayer, QObject *parent = nullptr);

    void update(double deltaTime) override;

    void takeDamage(int amount);

    class Bullet* fire();

    void setMoving(bool moving) { m_isMoving = moving; }
    bool isMoving() const { return m_isMoving; }

    int hp() const { return m_hp; }
    int maxHp() const { return m_maxHp; }
    bool isPlayer() const { return m_isPlayer; }

signals:
    void hpChanged();

private:
    void updateAI(double deltaTime);

    int m_hp;
    int m_maxHp;
    bool m_isPlayer;
    bool m_isMoving;

    double m_aiDecisionTimer;
    double m_aiFireTimer;
};