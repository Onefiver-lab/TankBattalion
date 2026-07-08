#pragma once
#include <QObject>
#include <QRectF>
#include <QVariantList>

class MapManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList mapData READ mapData NOTIFY mapChanged)

public:
    explicit MapManager(QObject *parent = nullptr);

    void loadDefaultMap();
    int getTileType(int row, int col) const;
    void setTileType(int row, int col, int type);

    bool checkCollision(const QRectF &box) const;
    bool handleBulletHit(const QRectF &bulletBox);

    QVariantList mapData() const;

    static const int ROWS = 15;
    static const int COLS = 20;
    static const int TILE_SIZE = 40;

signals:
    void mapChanged();

private:
    int m_map[ROWS][COLS];
};