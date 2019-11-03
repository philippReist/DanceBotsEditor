#include "PrimitiveList.h"
#include "Primitive.h"
#include <QDebug>

PrimitiveList::PrimitiveList(QObject* parent) : QAbstractListModel{ parent } {};

int PrimitiveList::rowCount(const QModelIndex& parent) const{
  Q_UNUSED(parent);
  return mData.size();
}

QVariant PrimitiveList::data(const QModelIndex& index, int role) const {
  if(Qt::UserRole + 1 == role
     && index.row() >= 0 && index.row() < mData.size()) {
    return QVariant::fromValue(mData[index.row()]);
  }
  else {
    return QVariant();
  }

}

Qt::ItemFlags PrimitiveList::flags(const QModelIndex& index) const {
  return Qt::ItemIsSelectable | Qt::ItemIsEditable | Qt::ItemIsEnabled
    | Qt::ItemIsDragEnabled | Qt::ItemNeverHasChildren;
}

QHash<int, QByteArray> PrimitiveList::roleNames() const {
  QHash<int, QByteArray> roles;
  roles[Qt::UserRole + 1] = "item";
  return roles;
}

void PrimitiveList::add(QObject* o) {
  const int nData = mData.size();
  // start insertion notification
  // data inserted at top level, hence first arg. QModelIndex()
  beginInsertRows(QModelIndex(), nData, nData);
  mData.append(o);
  // take ownership
   // This is very important to prevent items to be garbage collected in JS!!!
  o->setParent(this);
  endInsertRows();
}

void PrimitiveList::remove(const int index) {
  if(index < 0 || index >= mData.size()) {
    // object does not exist, return:
    return;
  }
  // start removal notification
  // data inserted at top level, hence first arg. QModelIndex()
  beginRemoveRows(QModelIndex(), index, index);
  mData.at(index)->setParent(nullptr);
  mData.removeAt(index);
  endRemoveRows();
}

void PrimitiveList::printPrimitives(void) const{
  size_t counter = 0;
  for(const auto& e : mData) {
    BasePrimitive* p = reinterpret_cast<BasePrimitive*>(e);
    qDebug() << "Item " << counter++ << " beatPos: " << p->mPositionBeat
      << ", beatL: " << p->mLengthBeat;
  }
}

void PrimitiveList::callDataChanged(const int index) {
  QModelIndex qmi = QAbstractItemModel::createIndex(index, 0);
  dataChanged(qmi, qmi, QVector<int>{Qt::UserRole + 1});
}

bool PrimitiveList::setData(const QModelIndex& index,
                            const QVariant& value,
                            int role) {
  qDebug() << "setData row " << index.row() << " role " << role;
  dataChanged(index, index, QVector<int>{Qt::UserRole + 1});
  return true;
}