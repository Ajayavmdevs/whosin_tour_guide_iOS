import UIKit
import Foundation
import ObjectMapper
import RealmSwift

public struct Pax: Codable, Equatable {
    public var age: Int
    public var id: Int

    public init(age: Int, id: Int) {
        self.age = age
        self.id = id
    }
}

public struct RoomPaxes: Codable, Equatable {
    public var pax: [Pax]

    public init(pax: [Pax]) {
        self.pax = pax
    }
}

public struct HotelBookingRequest: Codable, Equatable {
    public var hotelCode: String
    public var startDate: String
    public var endDate: String
    public var paxes: [RoomPaxes]

    public init(hotelCode: String, startDate: String, endDate: String, paxes: [RoomPaxes]) {
        self.hotelCode = hotelCode
        self.startDate = startDate
        self.endDate = endDate
        self.paxes = paxes
    }
}

// MARK: - Mutating helpers
public extension HotelBookingRequest {

    mutating func addRoom(defaultAge: Int = 20) {
        let nextId = nextPaxId()
        let newRoom = RoomPaxes(pax: [Pax(age: defaultAge, id: nextId)])
        paxes.append(newRoom)
    }

    mutating func setRoom(index: Int, adults: Int, children: Int) {
        guard index >= 0 && index < paxes.count else { return }
        var newPax: [Pax] = []
        var nextId = nextPaxId()

        for _ in 0..<adults {
            newPax.append(Pax(age: 20, id: nextId))
            nextId += 1
        }

        for _ in 0..<children {
            newPax.append(Pax(age: -1, id: nextId))
            nextId += 1
        }

        paxes[index] = RoomPaxes(pax: newPax)
    }

    mutating func setRoomCounts(index: Int, adults: Int, children: Int, preserveInfants: Bool = true) {
        guard index >= 0 && index < paxes.count else { return }

        var existingPax = paxes[index].pax
        var newPax: [Pax] = []

        var nextId = nextPaxId()

        let existingAdults = existingPax.filter { $0.age >= 12 }
        for i in 0..<adults {
            if i < existingAdults.count {
                newPax.append(existingAdults[i])
            } else {
                newPax.append(Pax(age: 20, id: nextId))
                nextId += 1
            }
        }

        let existingChildren = existingPax.filter { $0.age >= 0 && $0.age < 12 }
        for i in 0..<children {
            if i < existingChildren.count {
                newPax.append(existingChildren[i])
            } else {
                newPax.append(Pax(age: -1, id: nextId)) 
                nextId += 1
            }
        }

        paxes[index] = RoomPaxes(pax: newPax)
    }


    mutating func setDates(start: Date?, end: Date?) {
        if let s = start {
            #if canImport(UIKit)
            self.startDate = Utils.dateToString(s, format: "yyyy-MM-dd")
            #else
            self.startDate = Self.formatter.string(from: s)
            #endif
        } else {
            self.startDate = ""
        }

        if let e = end {
            #if canImport(UIKit)
            self.endDate = Utils.dateToString(e, format: "yyyy-MM-dd")
            #else
            self.endDate = Self.formatter.string(from: e)
            #endif
        } else {
            self.endDate = ""
        }
    }

    func totalCounts() -> (adults: Int, children: Int, infants: Int) {
        var adults = 0, children = 0, infants = 0
        for room in paxes {
            for p in room.pax {
                if p.age < 12 { children += 1 }
                else { adults += 1 }
            }
        }
        return (adults, children, infants)
    }

    /// Clears all booking data
    mutating func clearBookingData() {
        paxes.removeAll()
        startDate = ""
        endDate = ""
    }
}

// MARK: - Child age helpers
public extension HotelBookingRequest {
    func childAges(inRoom index: Int) -> [Int] {
        guard index >= 0 && index < paxes.count else { return [] }
        return paxes[index].pax.filter { $0.age < 12 }.map { $0.age }
    }
    
    mutating func setChildAge(roomIndex: Int, childIndex: Int, age: Int) {
        guard roomIndex >= 0 && roomIndex < paxes.count else { return }
        let cappedAge = max(0, min(age, 11))
        var room = paxes[roomIndex]
        var paxList = room.pax
        let childIndices = paxList.enumerated().filter { $0.element.age < 12 }.map { $0.offset }
        guard childIndex >= 0 && childIndex < childIndices.count else { return }
        let paxIdx = childIndices[childIndex]
        paxList[paxIdx].age = cappedAge
        room.pax = paxList
        paxes[roomIndex] = room
    }
}

// MARK: - Private helpers
private extension HotelBookingRequest {
    static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    /// Computes the next sequential pax ID starting from 1
    mutating func nextPaxId() -> Int {
        let maxId = paxes.flatMap { $0.pax }.map { $0.id }.max() ?? 0
        return maxId + 1
    }
}
