import { TestBed, inject } from '@angular/core/testing';

import { BiscottiConfigService } from './biscotti-config.service';

describe('BiscottiConfigService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [BiscottiConfigService]
    });
  });

  it('should be created', inject([BiscottiConfigService], (service: BiscottiConfigService) => {
    expect(service).toBeTruthy();
  }));
});
