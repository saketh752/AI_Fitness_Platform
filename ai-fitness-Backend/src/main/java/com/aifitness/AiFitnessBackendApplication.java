package com.aifitness;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

import com.aifitness.groq.GroqConfig;

@SpringBootApplication
@EnableConfigurationProperties(GroqConfig.class)
public class AiFitnessBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(AiFitnessBackendApplication.class, args);
	}

}
