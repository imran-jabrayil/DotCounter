//
//  GameStore.swift
//  DotCounter
//
//  Created by Imran Jabrayilov on 23.06.25.
//

import CloudKit
import SwiftUI

class GameStore: ObservableObject {
    @Published var games: [Game] = []
    @Published var isICloudAvailable: Bool = false

    private let database = CKContainer.default().privateCloudDatabase

    init() {
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                self.isICloudAvailable = (status == .available)
                if !self.isICloudAvailable {
                    print("⚠️ iCloud is not available: \(error?.localizedDescription ?? "Unknown reason")")
                }
            }
        }
    }

    func fetchGames() {
        guard isICloudAvailable else {
            print("Fetching skipped: iCloud not available")
            return
        }

        let query = CKQuery(recordType: "Game", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)

        var fetchedGames: [Game] = []

        operation.recordMatchedBlock = { recordID, result in
            switch result {
            case .success(let record):
                if let game = Game(record: record) {
                    fetchedGames.append(game)
                }
            case .failure(let error):
                print("Error fetching record \(recordID): \(error.localizedDescription)")
            }
        }

        operation.queryResultBlock = { result in
            DispatchQueue.main.async {
                self.games = fetchedGames.sorted(by: { $0.id.uuidString < $1.id.uuidString })
            }
        }

        database.add(operation)
    }

    func addGame(_ game: Game) {
        guard isICloudAvailable else {
            games.append(game)
            return
        }

        let record = game.toRecord()
        database.save(record) { _, error in
            DispatchQueue.main.async {
                if error == nil {
                    self.games.append(game)
                } else {
                    print("Error adding game: \(error!.localizedDescription)")
                }
            }
        }
    }

    func removeGame(_ game: Game) {
        guard isICloudAvailable else {
            games.removeAll { $0.id == game.id }
            return
        }

        let recordID = CKRecord.ID(recordName: game.id.uuidString)
        database.delete(withRecordID: recordID) { _, error in
            if error == nil {
                DispatchQueue.main.async {
                    self.games.removeAll { $0.id == game.id }
                }
            }
        }
    }

    func updateScore(for id: UUID, score1: Int, score2: Int) {
        guard let index = games.firstIndex(where: { $0.id == id }) else { return }
        // Update local state immediately for a responsive UI
        games[index].score1 = score1
        games[index].score2 = score2

        guard isICloudAvailable else { return }

        let recordID = CKRecord.ID(recordName: id.uuidString)

        // Helper function to handle saving with retries
        func saveUpdatedRecord(record: CKRecord, score1: Int, score2: Int) {
            record["score1"] = score1
            record["score2"] = score2

            database.save(record) { savedRecord, saveError in
                if let saveError = saveError as? CKError {
                    if saveError.code == .serverRecordChanged {
                        print("🔄 Oplock error: Server record changed. Retrying fetch and save.")
                        // Refetch the latest record and try again
                        self.database.fetch(withRecordID: recordID) { latestRecord, fetchError in
                            if let latestRecord = latestRecord {
                                saveUpdatedRecord(record: latestRecord, score1: score1, score2: score2) // Retry with the latest version
                            } else if let fetchError = fetchError {
                                print("❌ Failed to refetch record for retry: \(fetchError.localizedDescription)")
                            }
                        }
                    } else {
                        print("❌ Failed to save updated score: \(saveError.localizedDescription)")
                    }
                } else if let savedRecord = savedRecord {
                    print("✅ Score updated successfully for record: \(savedRecord.recordID.recordName)")
                    // Optionally, update the local 'games' array with the savedRecord's version
                    // This is good practice if other fields could also change
                } else {
                     print("❌ Failed to save updated score: Unknown error.")
                }
            }
        }

        // Initial fetch to get the record to update
        database.fetch(withRecordID: recordID) { record, fetchError in
            if let record = record {
                saveUpdatedRecord(record: record, score1: score1, score2: score2)
            } else if let fetchError = fetchError {
                print("❌ Failed to fetch existing record: \(fetchError.localizedDescription)")
            }
        }
    }
}

