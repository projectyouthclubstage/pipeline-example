package com.example.demo.endpoint;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequestMapping("/v1")
@RestController
public class HelloWorld {


    @RequestMapping("hello")
    @GetMapping(produces = "application/json")
    ResponseEntity<String> getHello(){
        return new ResponseEntity<>("HelloMyWorld",HttpStatus.OK);
    }
}
