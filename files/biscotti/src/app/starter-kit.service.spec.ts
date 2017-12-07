import { TestBed, inject } from '@angular/core/testing';

import { StarterKitService } from './starter-kit.service';

describe('StarterKitService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [StarterKitService]
    });
  });

  it('should be created', inject([StarterKitService], (service: StarterKitService) => {
    expect(service).toBeTruthy();
  }));
});
