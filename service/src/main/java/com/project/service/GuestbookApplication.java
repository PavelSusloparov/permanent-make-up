package com.project.service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.web.bind.annotation.RequestMapping;

@EnableDiscoveryClient
@SpringBootApplication
public class GuestbookApplication {

	public static void main(String[] args) {
		SpringApplication.run(GuestbookApplication.class, args);
	}

	@RequestMapping("/greeting")
	public String greeting() {
		return "Hello from EurekaClient!";
	}
}