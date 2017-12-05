import {
  Component,
  OnInit
} from '@angular/core';

import {
  FormsModule,
  FormBuilder,
  FormControl,
  FormGroup,
  Validators
} from '@angular/forms';

import { MatSnackBar } from '@angular/material';

import { AuthRequest } from './auth-request.type';
import { BiscottiConfig } from '../biscotti-config.type';
import { BiscottiConfigService } from '../biscotti-config.service';
import { BiscottiAuthService } from '../biscotti-auth.service';

@Component({
  selector: 'app-biscotti-auth',
  templateUrl: './biscotti-auth.component.html',
  styleUrls: ['./biscotti-auth.component.css']
})
export class BiscottiAuthComponent implements OnInit {
  public model = new AuthRequest('');
  public config: BiscottiConfig;

  constructor(
    private authService: BiscottiAuthService,
    private configService: BiscottiConfigService,
    private snackBar: MatSnackBar
  ) {}

  ngOnInit() {
    this.configService.config.subscribe(c => this.config = c);
  }

  notifyError(message: string, action: string) {
    this.snackBar.open(message, action, {
      duration: 4000,
    });
  }

  onSubmit(form) {
    this
      .authService
      .authorize(this.model)
      .subscribe(
        () => { },
        err => {
          let msg = '';
          if (err.error instanceof Error) {
            // A client-side or network error occurred.
            msg = `Client Error: ${err.error.message}`;
          } else {
            // The backend returned an unsuccessful response code.
            msg = `Backend Error: ${err.status} ${err.statusText}`;
          }
          this.notifyError(msg, 'Authorization Failed');
        }
      );
  }
}
