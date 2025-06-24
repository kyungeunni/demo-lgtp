package com.example.app2.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class WorldController {
    @GetMapping("/world")
    public String world() {
        return "app2 world!";
    }
} 