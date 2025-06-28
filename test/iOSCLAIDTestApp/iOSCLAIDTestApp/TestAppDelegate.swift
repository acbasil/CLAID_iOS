//
//  TestAppDelegate.swift
//  SpeziCLAID
//
//  Created by Patrick Langer on 10.03.2025.
//

@testable import Spezi
import Foundation
import CLAID
import UIKit

final actor MyModule : CLAIDModule {
 
    @Dependency
    var claidRuntime = CLAIDRuntime()
    let moduleHandle: ModuleHandle
    
    init(
        id: String = "MyModule"
    ) {
        moduleHandle = Self.makeDefaultHandle(id: id)
        
        // TODO: @Patrick How to set channels?
        // set channel
        _ = self.outputChannels(["walkietalkie": "channel1"])
    }

    
    func run() async throws {
        print("Run called!")
        
        await sendPing()

    }
    
    func terminate() async {
        
    }
    
    @Sendable
    func sendPing() async {
        
        print("start sendPing")
        guard let output = getOutputChannels()["walkietalkie"] else {
            await moduleWarning("Output channel 'walkietalkie' not configured.")
            return
        }
        do {
            let chan: Channel<String> = try await publish(output, dataTypeExample: String())
            await chan.post("Ping from MyModule")
        } catch {
            await moduleError("Failed to send ping: \(error)")
        }
    }
    
}

final actor DummyReceiver : CLAIDModule {
 
    @Dependency
    var claidRuntime = CLAIDRuntime()
    let moduleHandle: ModuleHandle
    
    init(
        id: String = "DummyReceiver"
    ) {
        moduleHandle = Self.makeDefaultHandle(id: id)
        
        // set channel
        _ = self.inputChannels(["walkietalkie": "channel1"])

    }

    func run() async throws {
        print("Run called!")
        
        guard let input = getInputChannels()["walkietalkie"] else {
            await moduleWarning("Input channel 'walkietalkie' not configured.")
            return
        }
        
        let _: Channel<String> = try await subscribe(input, dataTypeExample: String()) { data in
            let msg = await data.getData()
            print("DummyReceiver received: \(msg)")
        }

    }
    
    func terminate() async {
        
    }
}


class TestAppDelegate : SpeziAppDelegate {
    override var configuration: Configuration  {
        Configuration {
            // TODO: @Patrick Necessary?
            MyModule()
                .outputChannels(["walkietalkie": "channel1"])
            DummyReceiver()
                .inputChannels(["walkietalkie": "channel1"])
        }
    }
}

// error message
// TODO: FYI

/*
 [28.6.2025 14:44:20 | CLAID C++ INFO | MIDDLEWARE] InitRuntime: DummyReceiver
 [28.6.2025 14:44:20 | CLAID C++ INFO | MIDDLEWARE] InitRuntime num channel pakets for module DummyReceiver: 1
 [28.6.2025 14:44:20 | CLAID C++ WARNING | MIDDLEWARE] Invalid subscribed channel "channel1 for Module "DummyReceiver".Could not find where this Channel is connected/mapped to, as it was not found in the moduleInputChannelsToConnectionMap.
 Was the channel specified in the "input_channels" property of the Module?
 [28.6.2025 14:44:20 | CLAID C++ INFO | MIDDLEWARE] Status ok
 [28.6.2025 14:44:20 | CLAID C++ INFO | MIDDLEWARE] Set module loaded
 [28.6.2025 14:44:20 | CLAID C++ INFO | MIDDLEWARE] InitRuntime: MyModule
 [28.6.2025 14:44:20 | CLAID C++ INFO | MIDDLEWARE] InitRuntime num channel pakets for module MyModule: 1
 [28.6.2025 14:44:20 | CLAID C++ WARNING | MIDDLEWARE] Invalid published channel "channel1for Module "MyModule".Could not find where this Channel is connected/mapped to, as it was not found in the moduleOutputChannelsToConnectionMap.
 Was the channel specified in the "output_channels" property of the Module?
 [28.6.2025 14:44:20 | CLAID C++ INFO | MIDDLEWARE] Status ok
 [28.6.2025 14:44:20 | CLAID C++ INFO | MIDDLEWARE] Set module loaded
 [28.6.2025 14:44:20 | CLAID C++ INFO | MIDDLEWARE] Set runtime is initializing false
 */
