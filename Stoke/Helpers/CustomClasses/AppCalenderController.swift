//
//  AppCalenderController.swift
//  Stoke
//
//  Created by Admin on 09/04/21.
//

import Foundation

struct  EventCalendar : CustomStringConvertible{
    
    var date:Date
    var toShowDate:String
    var timestamp:Double
    var endTimestamp:Double
    var isCurrent:Bool
    var weekDay:String
    var calendarDate:String
    var isOngoing:Bool = false
    init(d:Date) {
        date = d
        if Calendar.current.isDateInToday(d){
            toShowDate = "Today"
            isCurrent = true
            self.weekDay = ""
            self.calendarDate = ""
        }else{
            isCurrent = false
            let weekDay = d.toString(dateFormat: "EEE")
            let calendarDate = d.toString(dateFormat: "M/d")
            toShowDate = weekDay + " " + calendarDate
            self.weekDay = weekDay
            self.calendarDate = calendarDate
        }
        timestamp = d.startOfDay.timeIntervalSince1970 * 1000
        endTimestamp = d.endOfDay.timeIntervalSince1970 * 1000
    }
    
    init(){
        date = Date()
        toShowDate = "Ongoing"
        isCurrent = false
        isOngoing = true
        timestamp = date.startOfDay.timeIntervalSince1970 * 1000
        endTimestamp = date.endOfDay.timeIntervalSince1970 * 1000
        weekDay = ""
        calendarDate = ""
    }
    var description: String {
        return "Date -\(date) \n toShowDate - \(toShowDate) \n timestamp - \(timestamp)"
    }
}


class AppCalendar{
    
    static let shared = AppCalendar()
    private init(){}
    
    var oneWeek: [EventCalendar] = []
    var fullCalendar: [EventCalendar] = []
    
    func returnOneWeekCalender(_ isOngoing:Bool) -> [EventCalendar]{
        var dataSource = [EventCalendar]()
        if isOngoing{
            dataSource.append(EventCalendar())
        }
        dataSource.append(EventCalendar(d: Date().startOfDay))
        for i in 1...6{
            let d = Date().returnNextDate(counter: i)
            dataSource.append(EventCalendar(d: d))
        }
        oneWeek = dataSource
        return oneWeek
    }
    
    func returnFullCalender(_ isObgoing:Bool) -> [EventCalendar]{
        var dataSource = [EventCalendar]()
        let backDays = [-3,-2,-1]
        for i in backDays{
            let d = Date().returnNextDate(counter: i)
            dataSource.append(EventCalendar(d: d))
        }
        if isObgoing{
            dataSource.append(EventCalendar())
        }
        dataSource.append(EventCalendar(d: Date().startOfDay))
        for i in 1...6{
            let d = Date().returnNextDate(counter: i)
            dataSource.append(EventCalendar(d: d))
        }
        fullCalendar = dataSource
        return fullCalendar
    }
    
}



extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    func returnNextDate(counter:Int) -> Date{
        var components = DateComponents()
        components.day = counter
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }
}
