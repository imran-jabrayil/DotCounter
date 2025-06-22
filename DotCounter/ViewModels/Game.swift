//
//  Game.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 23.06.25.
//

import CloudKit

struct Game: Identifiable {
    let id: UUID
    let team1: String
    let team2: String
    var score1: Int
    var score2: Int

    init(id: UUID = UUID(), team1: String, team2: String, score1: Int = 0, score2: Int = 0) {
        self.id = id
        self.team1 = team1
        self.team2 = team2
        self.score1 = score1
        self.score2 = score2
    }

    init?(record: CKRecord) {
        guard let team1 = record["team1"] as? String,
              let team2 = record["team2"] as? String,
              let score1 = record["score1"] as? Int,
              let score2 = record["score2"] as? Int,
              let idString = record["id"] as? String,
              let uuid = UUID(uuidString: idString) else {
            return nil
        }
        self.id = uuid
        self.team1 = team1
        self.team2 = team2
        self.score1 = score1
        self.score2 = score2
    }

    func toRecord() -> CKRecord {
        let record = CKRecord(recordType: "Game", recordID: CKRecord.ID(recordName: id.uuidString))
        record["id"] = id.uuidString
        record["team1"] = team1
        record["team2"] = team2
        record["score1"] = score1
        record["score2"] = score2
        return record
    }
}
