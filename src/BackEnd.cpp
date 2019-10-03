#include "BackEnd.hpp"
#include "QtDebug"
#include <stdio.h>
#include <QThread>
#include <QEventLoop>
#include <QtConcurrent>

BackEnd::BackEnd(QObject *parent) :
  QObject{ parent }, mAudioFile{},
  mLoadStatus{ "Idle" }, mLoadFutureWatcher{},
  mLoadFuture{}
{
}

//** PROPERTY SETTERS GETTERS AND NOTIFIERS **//
QString BackEnd::songTitle()
{
  return mSongTitle;
}

QString BackEnd::songArtist()
{
    return mSongArtist;
}

QString BackEnd::loadStatus()
{
  return mLoadStatus;
}

void BackEnd::setSongArtist(const QString &name)
{
    if (name == mSongArtist)
        return;

    mSongArtist = name;
}

void BackEnd::setSongTitle(const QString& name)
{
  if (name == mSongTitle)
    return;

  mSongTitle = name;
}

Q_INVOKABLE void BackEnd::loadMP3(const QString& filePath) {
  // convert to qurl and localized file path:
  QUrl localFilePath{ filePath };
  qDebug() << "starting load thread";
  connect(&mLoadFutureWatcher, &QFutureWatcher<bool>::finished,
          this, &BackEnd::handleDoneLoading);
  mLoadFuture = QtConcurrent::run(this, &BackEnd::loadMP3Worker,
                                  localFilePath.toLocalFile());
  mLoadFutureWatcher.setFuture(mLoadFuture);
}

void BackEnd::handleDoneLoading(void) {
  emit doneLoading(mLoadFuture.result());
}

bool BackEnd::loadMP3Worker(const QString& filePath) {
  mLoadStatus = "Reading and decoding MP3...";
  emit loadStatusChanged();
  const AudioFile::Result res = mAudioFile.Load(filePath);

  if (!(AudioFile::Result::kSuccess == res)) {
    // loading failed

    return false;
  }

  // otherwise, loading succeeded, set song and artist name:
  mSongArtist = QString{ mAudioFile.GetArtist().c_str() };
  mSongTitle = QString{ mAudioFile.GetTitle().c_str() };

  mLoadStatus = "Detecting Beats...";
  emit loadStatusChanged();
  QThread::msleep(2000);
  mLoadStatus = "Done.";
  emit loadStatusChanged();
  QThread::msleep(1000);
  return true;
}