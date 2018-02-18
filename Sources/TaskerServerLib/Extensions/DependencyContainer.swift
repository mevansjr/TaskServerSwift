//
//  DependencyContainer.swift
//  TaskerServerPackageDescription
//
//  Created by Marcin Czachurski on 12.02.2018.
//

import Foundation
import Dip

extension DependencyContainer {
    public func configure(withConfiguration configuration: Configuration) {
        self.registerConfiguration(container: self, configuration: configuration)
        self.registerRepositories(container: self)
        self.registerControllers(container: self)
    }
    
    public func resolveAllControllers() -> [Controller] {
        let controllers:[Controller] = [
            try! self.resolve() as HealthController,
            try! self.resolve() as TasksController,
            try! self.resolve() as UsersController
        ]
        
        return controllers
    }
    
    private func registerConfiguration(container: DependencyContainer, configuration: Configuration) {
        container.register(.singleton) { configuration }
    }
    
    private func registerRepositories(container: DependencyContainer) {
        container.register { TasksRepository(configuration: $0) as TasksRepositoryProtocol }
        container.register { UsersRepository(configuration: $0) as UsersRepositoryProtocol }
    }
    
    private func registerControllers(container: DependencyContainer) {
        container.register { TasksController(tasksRepository: $0) }
        container.register { UsersController(usersRepository: $0) }
        container.register { HealthController() }
    }
}

