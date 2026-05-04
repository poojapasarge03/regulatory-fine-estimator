package com.internship.tool.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.internship.tool.entity.Role;
import com.internship.tool.entity.User;
import com.internship.tool.repository.UserRepository;

@Configuration
public class DataInitializer {

    @Bean
    CommandLineRunner init(UserRepository repo, PasswordEncoder encoder) {
        return args -> {
            User adminUser = repo.findByUsername("admin").orElseGet(User::new);
            adminUser.setUsername("admin");
            adminUser.setPassword(encoder.encode("admin123"));
            adminUser.setRole(Role.ADMIN);
            repo.save(adminUser);

            User userUser = repo.findByUsername("user").orElseGet(User::new);
            userUser.setUsername("user");
            userUser.setPassword(encoder.encode("user123"));
            userUser.setRole(Role.USER);
            repo.save(userUser);
        };
    }
}
