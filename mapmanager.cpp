#include "mapmanager.h"

MapManager::MapManager(QObject *parent) : QObject(parent) {
    loadDefaultMap();
}

void MapManager::loadDefaultMap() {
    int demoMap[ROWS][COLS] = {
        {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
        {0,1,1,0,1,1,0,2,2,0,0,2,2,0,1,1,0,1,1,0},
        {0,1,1,0,1,1,0,0,0,0,0,0,0,0,1,1,0,1,1,0},
        {0,1,1,0,1,1,0,1,1,1,1,1,1,0,1,1,0,1,1,0},
        {0,0,0,0,0,0,0,1,2,2,2,2,1,0,0,0,0,0,0,0},
        {2,2,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,2,2},
        {0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0},
        {1,1,0,1,1,0,2,2,0,0,0,0,2,2,0,1,1,0,1,1},
        {0,0,0,0,0,0,2,2,0,0,0,0,2,2,0,0,0,0,0,0},
        {0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0},
        {0,1,0,1,0,1,1,1,1,0,0,1,1,1,1,0,1,0,1,0},
        {0,1,0,1,0,1,0,0,0,0,0,0,0,0,1,0,1,0,1,0},
        {0,0,0,0,0,1,0,1,1,1,1,1,1,0,1,0,0,0,0,0},
        {0,0,0,0,0,1,0,1,0,0,0,0,1,0,1,0,0,0,0,0},
        {0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0}
    };

    for(int r = 0; r < ROWS; ++r) {
        for(int c = 0; c < COLS; ++c) {
            m_map[r][c] = demoMap[r][c];
        }
    }
    emit mapChanged();
}

int MapManager::getTileType(int row, int col) const {
    if (row < 0 || row >= ROWS || col < 0 || col >= COLS) return 2;
    return m_map[row][col];
}

void MapManager::setTileType(int row, int col, int type) {
    if (row >= 0 && row < ROWS && col >= 0 && col < COLS) {
        m_map[row][col] = type;
        emit mapChanged();
    }
}

bool MapManager::checkCollision(const QRectF &box) const {
    int startCol = static_cast<int>(box.left()) / TILE_SIZE;
    int endCol = static_cast<int>(box.right()) / TILE_SIZE;
    int startRow = static_cast<int>(box.top()) / TILE_SIZE;
    int endRow = static_cast<int>(box.bottom()) / TILE_SIZE;

    for (int r = startRow; r <= endRow; ++r) {
        for (int c = startCol; c <= endCol; ++c) {
            if (getTileType(r, c) != 0) {
                return true;
            }
        }
    }
    return false;
}

bool MapManager::handleBulletHit(const QRectF &bulletBox) {
    int startCol = static_cast<int>(bulletBox.left()) / TILE_SIZE;
    int endCol = static_cast<int>(bulletBox.right()) / TILE_SIZE;
    int startRow = static_cast<int>(bulletBox.top()) / TILE_SIZE;
    int endRow = static_cast<int>(bulletBox.bottom()) / TILE_SIZE;

    for (int r = startRow; r <= endRow; ++r) {
        for (int c = startCol; c <= endCol; ++c) {
            int type = getTileType(r, c);
            if (type == 1) {
                setTileType(r, c, 0);
                return true;
            } else if (type == 2) {
                return true;
            }
        }
    }
    return false;
}

QVariantList MapManager::mapData() const {
    QVariantList list;
    for (int r = 0; r < ROWS; ++r) {
        for (int c = 0; c < COLS; ++c) {
            list.append(m_map[r][c]);
        }
    }
    return list;
}