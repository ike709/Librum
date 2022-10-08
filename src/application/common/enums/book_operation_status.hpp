#pragma once
#include <QObject>


namespace application
{
    Q_NAMESPACE

    enum class BookOperationStatus
    {
        Success,
        OpeningBookFailed,
        BookDoesNotExist,
        BookAlreadyExists,
        PropertyDoesNotExist,
        TagDoesNotExist,
        TagAlreadyExists,
        OperationFailed
    };
    
    Q_ENUM_NS(BookOperationStatus)

} // namespace application