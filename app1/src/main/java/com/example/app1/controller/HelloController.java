package com.example.app1.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
public class HelloController {
    private final RestTemplate restTemplate = new RestTemplate();

    @GetMapping("/hello")
    public String hello() {
        String response = restTemplate.getForObject("http://app2:8081/world", String.class);
        return "app1 → " + response;
    }
} 