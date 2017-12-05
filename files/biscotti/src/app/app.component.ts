import {
  Component,
  OnInit,
} from '@angular/core';

import { BiscottiConfig } from './biscotti-config.type';
import { BiscottiConfigService } from './biscotti-config.service';
import { BiscottiAuthService } from './biscotti-auth.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  title = 'app';

  config: BiscottiConfig;
  token: string;

  constructor(
    private configService: BiscottiConfigService,
    private authService: BiscottiAuthService
  ) {}

  ngOnInit() {
    this.configService.config.subscribe(c => this.config = c);
    this.authService.token.subscribe(t => this.token = t);
  }

  showAuth(): boolean {
    return (this.config.authRequired && this.token === '' ? true : false);
  }

  showSetup(): boolean { return !this.showAuth(); }
}
