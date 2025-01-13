//
//  SkillModel.swift
//  VolleyballAcademy
//
//  Created by Jesse Liang on 2025/1/9.
//

import Foundation

struct SkillModel {
    let name: String
    let description: String
    let icon: String
}

let skills = [
    SkillModel(name: "Serving", description: "Start the rally with a strong serve.", icon: "⚡"),
    SkillModel(name: "Passing", description: "Control the ball and pass to a teammate.", icon: "🏐"),
    SkillModel(name: "Spiking", description: "Hit the ball with power to score.", icon: "🔥")
]
