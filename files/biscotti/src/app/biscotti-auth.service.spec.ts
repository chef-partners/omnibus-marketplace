import { TestBed, inject } from '@angular/core/testing';

import { BiscottiAuthService } from './biscotti-auth.service';

describe('BiscottiAuthService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [BiscottiAuthService]
    });
  });

  it('should be created', inject([BiscottiAuthService], (service: BiscottiAuthService) => {
    expect(service).toBeTruthy();
  }));
});
