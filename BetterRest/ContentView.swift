//
//  ContentView.swift
//  BetterRest
//
//  Created by Luis Enrique Rosas Espinoza on 31/12/23.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var bedtime = ""
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    
                    Section("When do you want to wake up?") {
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .onChange(of: wakeUp) { oldValue, newValue in
                                calculateBedtime()
                            }
                    }
                    
                    Section("Desired amount of sleep") {
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                            .onChange(of: sleepAmount) { oldValue, newValue in
                                calculateBedtime()
                            }
                    }
                    
                    Section("Daily coffee intake") {
                        Picker("Cups", selection: $coffeeAmount) {
                            ForEach(1..<21) { cup in
                                Text("\(cup) \(cup == 1 ? "cup" : "cups")")
                            }
                        }
                    }
                }
                .navigationTitle("BetterRest")
                
                Spacer()
                
                Text("Your ideal bedtime is…")
                Text((bedtime.isEmpty) ? "00:00" : bedtime)
                    .font(.largeTitle)
                    .padding(.bottom)
                
                Spacer()
            }
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Int64(hour + minute), estimatedSleep: sleepAmount, coffee: Int64(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            bedtime = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            bedtime = "Error calculating bedtime"
        }
    }
}

#Preview {
    ContentView()
}
